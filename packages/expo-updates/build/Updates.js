import { UnavailabilityError } from '@unimodules/core';
import BareExpoUpdates from './ExpoUpdates';
import ManagedExpoUpdates from './ExponentUpdates';
export * from './Updates.types';
// If ManagedExpoUpdates is nonnull, we must either be in a managed workflow project, or an ExpoKit
// project with this package installed (so the developer can switch to the new API). In either case,
// ManagedExpoUpdates is the "active" underlying Updates module implementation, so we'll want to use
// it. Otherwise, we can safely fall back to BareExpoUpdates.
// TODO(eric): remove ManagedExpoUpdates once NativeModules.ExponentUpdates is fully decommissioned.
const ExpoUpdates = ManagedExpoUpdates ?? BareExpoUpdates;
export const localAssets = ExpoUpdates.localAssets ?? {};
export const isEmergencyLaunch = ExpoUpdates.isEmergencyLaunch || false;
let _manifest = ExpoUpdates.manifest;
if (ExpoUpdates.manifestString) {
    _manifest = JSON.parse(ExpoUpdates.manifestString);
}
export const manifest = _manifest ?? {};
export async function reloadAsync() {
    if (!ExpoUpdates.reload) {
        throw new UnavailabilityError('Updates', 'reloadAsync');
    }
    await ExpoUpdates.reload();
}
export async function checkForUpdateAsync() {
    if (!ExpoUpdates.checkForUpdateAsync) {
        throw new UnavailabilityError('Updates', 'checkForUpdateAsync');
    }
    const result = await ExpoUpdates.checkForUpdateAsync();
    if (result.manifestString) {
        result.manifest = JSON.parse(result.manifestString);
        delete result.manifestString;
    }
    return result;
}
export async function fetchUpdateAsync() {
    if (!ExpoUpdates.fetchUpdateAsync) {
        throw new UnavailabilityError('Updates', 'fetchUpdateAsync');
    }
    const result = await ExpoUpdates.fetchUpdateAsync();
    if (result.manifestString) {
        result.manifest = JSON.parse(result.manifestString);
        delete result.manifestString;
    }
    return result;
}
export function addListener(listener) {
    if (!ExpoUpdates.addListener) {
        throw new UnavailabilityError('Updates', 'addListener');
    }
    return ExpoUpdates.addListener(listener);
}
//# sourceMappingURL=Updates.js.map