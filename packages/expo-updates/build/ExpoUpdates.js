import { NativeModulesProxy, RCTDeviceEventEmitter } from '@unimodules/core';
import { EventEmitter } from 'fbemitter';
export default {
    ...(NativeModulesProxy.ExpoUpdates ?? {}),
    addListener(listener) {
        const emitter = _getEmitter();
        return emitter.addListener('Expo.updatesEvent', listener);
    },
};
let _emitter;
function _getEmitter() {
    if (!_emitter) {
        _emitter = new EventEmitter();
        RCTDeviceEventEmitter.addListener('Expo.nativeUpdatesEvent', _emitEvent);
    }
    return _emitter;
}
function _emitEvent(params) {
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
//# sourceMappingURL=ExpoUpdates.js.map