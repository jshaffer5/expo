import { EventSubscription } from 'fbemitter';
import { UpdateCheckResult, UpdateFetchResult, Listener, UpdateEvent } from './Updates.types';
declare const _default: {
    readonly name: string;
    readonly manifest: any;
    reload(): Promise<void>;
    checkForUpdateAsync(): Promise<UpdateCheckResult>;
    fetchUpdateAsync(): Promise<UpdateFetchResult>;
    addListener(listener: Listener<UpdateEvent>): EventSubscription;
} | null;
export default _default;
