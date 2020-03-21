import { NativeModulesProxy, RCTDeviceEventEmitter } from '@unimodules/core';
import { EventEmitter, EventSubscription } from 'fbemitter';

import { UpdateEvent, Listener } from './Updates.types';

export default {
  ...(NativeModulesProxy.ExpoUpdates ?? ({} as any)),
  addListener(listener: Listener<UpdateEvent>): EventSubscription {
    const emitter = _getEmitter();
    return emitter.addListener('Expo.updatesEvent', listener);
  },
} as any;

let _emitter: EventEmitter | null;

function _getEmitter(): EventEmitter {
  if (!_emitter) {
    _emitter = new EventEmitter();
    RCTDeviceEventEmitter.addListener('Expo.nativeUpdatesEvent', _emitEvent);
  }
  return _emitter;
}

function _emitEvent(params): void {
  let newParams = params;
  if (typeof params === 'string') {
    newParams = JSON.parse(params);
  }
  if (newParams.manifestString) {
    newParams.manifest = JSON.parse(newParams.manifestString);
    delete newParams.manifestString;
  }

  if (!_emitter) {
    throw new Error(`EventEmitter must be initialized to use from its listener`);
  }
  _emitter.emit('Expo.updatesEvent', newParams);
}
