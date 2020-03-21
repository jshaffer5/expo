import { RCTDeviceEventEmitter } from '@unimodules/core';
import Constants from 'expo-constants';
import { EventEmitter, EventSubscription } from 'fbemitter';
import { NativeModules } from 'react-native';

import {
  UpdateCheckResult,
  UpdateFetchResult,
  Listener,
  UpdateEvent,
  UpdateEventType,
} from './Updates.types';

export default NativeModules.ExponentUpdates
  ? {
      get name(): string {
        return 'ExponentUpdates';
      },
      get manifest(): any {
        return Constants.manifest;
      },
      async reload(): Promise<void> {
        await NativeModules.ExponentUpdates.reloadFromCache();
      },
      async checkForUpdateAsync(): Promise<UpdateCheckResult> {
        const result = await NativeModules.ExponentUpdates.checkForUpdateAsync();
        if (!result) {
          return { isAvailable: false };
        }

        return {
          isAvailable: true,
          manifest: typeof result === 'string' ? JSON.parse(result) : result,
        };
      },
      async fetchUpdateAsync(): Promise<UpdateFetchResult> {
        _isFetchingUpdate = true;
        const result = await NativeModules.ExponentUpdates.fetchUpdateAsync();
        setTimeout(() => {
          _isFetchingUpdate = false;
        }, 1000);

        if (!result) {
          return { isNew: false };
        }

        return {
          isNew: true,
          manifest: typeof result === 'string' ? JSON.parse(result) : result,
        };
      },
      addListener(listener: Listener<UpdateEvent>): EventSubscription {
        const emitter = _getEmitter();
        return emitter.addListener('Expo.updatesEvent', listener);
      },
    }
  : null;

let _emitter: EventEmitter | null;
let _isFetchingUpdate = false;

function _getEmitter(): EventEmitter {
  if (!_emitter) {
    _emitter = new EventEmitter();
    RCTDeviceEventEmitter.addListener('Exponent.nativeUpdatesEvent', _emitEvent);
  }
  return _emitter;
}

function _emitEvent(params): void {
  // The legacy implementation emits additional events during the `fetchUpdateAsync` call. Since the
  // new implementation does not do this, we should ignore these events.
  if (_isFetchingUpdate) {
    return;
  }

  let newParams = params;
  if (typeof params === 'string') {
    newParams = JSON.parse(params);
  }
  if (newParams.manifestString) {
    newParams.manifest = JSON.parse(newParams.manifestString);
    delete newParams.manifestString;
  }

  // transform legacy event types
  if (
    newParams.type === LegacyUpdatesEventType.DOWNLOAD_STARTED ||
    newParams.type === LegacyUpdatesEventType.DOWNLOAD_PROGRESS
  ) {
    return;
  } else if (newParams.type === LegacyUpdatesEventType.DOWNLOAD_FINISHED) {
    newParams.type = UpdateEventType.UPDATE_AVAILABLE;
  }

  if (!_emitter) {
    throw new Error(`EventEmitter must be initialized to use from its listener`);
  }
  _emitter.emit('Expo.updatesEvent', newParams);
}

enum LegacyUpdatesEventType {
  DOWNLOAD_STARTED = 'downloadStart',
  DOWNLOAD_PROGRESS = 'downloadProgress',
  DOWNLOAD_FINISHED = 'downloadFinished',
  NO_UPDATE_AVAILABLE = 'noUpdateAvailable',
  ERROR = 'error',
}
