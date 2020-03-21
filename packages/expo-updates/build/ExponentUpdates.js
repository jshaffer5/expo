import { RCTDeviceEventEmitter } from '@unimodules/core';
import Constants from 'expo-constants';
import { EventEmitter } from 'fbemitter';
import { NativeModules } from 'react-native';
import { UpdateEventType, } from './Updates.types';
export default NativeModules.ExponentUpdates
    ? {
        get name() {
            return 'ExponentUpdates';
        },
        get manifest() {
            return Constants.manifest;
        },
        async reload() {
            await NativeModules.ExponentUpdates.reloadFromCache();
        },
        async checkForUpdateAsync() {
            const result = await NativeModules.ExponentUpdates.checkForUpdateAsync();
            if (!result) {
                return { isAvailable: false };
            }
            return {
                isAvailable: true,
                manifest: typeof result === 'string' ? JSON.parse(result) : result,
            };
        },
        async fetchUpdateAsync() {
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
        addListener(listener) {
            const emitter = _getEmitter();
            return emitter.addListener('Expo.updatesEvent', listener);
        },
    }
    : null;
let _emitter;
let _isFetchingUpdate = false;
function _getEmitter() {
    if (!_emitter) {
        _emitter = new EventEmitter();
        RCTDeviceEventEmitter.addListener('Exponent.nativeUpdatesEvent', _emitEvent);
    }
    return _emitter;
}
function _emitEvent(params) {
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
    if (newParams.type === LegacyUpdatesEventType.DOWNLOAD_STARTED ||
        newParams.type === LegacyUpdatesEventType.DOWNLOAD_PROGRESS) {
        return;
    }
    else if (newParams.type === LegacyUpdatesEventType.DOWNLOAD_FINISHED) {
        newParams.type = UpdateEventType.UPDATE_AVAILABLE;
    }
    if (!_emitter) {
        throw new Error(`EventEmitter must be initialized to use from its listener`);
    }
    _emitter.emit('Expo.updatesEvent', newParams);
}
var LegacyUpdatesEventType;
(function (LegacyUpdatesEventType) {
    LegacyUpdatesEventType["DOWNLOAD_STARTED"] = "downloadStart";
    LegacyUpdatesEventType["DOWNLOAD_PROGRESS"] = "downloadProgress";
    LegacyUpdatesEventType["DOWNLOAD_FINISHED"] = "downloadFinished";
    LegacyUpdatesEventType["NO_UPDATE_AVAILABLE"] = "noUpdateAvailable";
    LegacyUpdatesEventType["ERROR"] = "error";
})(LegacyUpdatesEventType || (LegacyUpdatesEventType = {}));
//# sourceMappingURL=ExponentUpdates.js.map