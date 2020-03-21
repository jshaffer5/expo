import { UnavailabilityError } from '@unimodules/core';
import { EventSubscription } from 'fbemitter';

import BareExpoUpdates from './ExpoUpdates';
import ManagedExpoUpdates from './ExponentUpdates';
import {
  Listener,
  LocalAssets,
  Manifest,
  UpdateCheckResult,
  UpdateEvent,
  UpdateFetchResult,
} from './Updates.types';

export * from './Updates.types';

// If ManagedExpoUpdates is nonnull, we must either be in a managed workflow project, or an ExpoKit
// project with this package installed (so the developer can switch to the new API). In either case,
// ManagedExpoUpdates is the "active" underlying Updates module implementation, so we'll want to use
// it. Otherwise, we can safely fall back to BareExpoUpdates.
// TODO(eric): remove ManagedExpoUpdates once NativeModules.ExponentUpdates is fully decommissioned.
const ExpoUpdates = ManagedExpoUpdates ?? BareExpoUpdates;

export const localAssets: LocalAssets = ExpoUpdates.localAssets ?? {};
export const isEmergencyLaunch: boolean = ExpoUpdates.isEmergencyLaunch || false;

let _manifest = ExpoUpdates.manifest;
if (ExpoUpdates.manifestString) {
  _manifest = JSON.parse(ExpoUpdates.manifestString);
}
export const manifest: Manifest | object = _manifest ?? {};

export async function reloadAsync(): Promise<void> {
  if (!ExpoUpdates.reload) {
    throw new UnavailabilityError('Updates', 'reloadAsync');
  }
  await ExpoUpdates.reload();
}

export async function checkForUpdateAsync(): Promise<UpdateCheckResult> {
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

export async function fetchUpdateAsync(): Promise<UpdateFetchResult> {
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

export function addListener(listener: Listener<UpdateEvent>): EventSubscription {
  if (!ExpoUpdates.addListener) {
    throw new UnavailabilityError('Updates', 'addListener');
  }
  return ExpoUpdates.addListener(listener);
}
