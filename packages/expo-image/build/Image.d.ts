import React from 'react';
import { AccessibilityProps, ImageResizeMode, ImageSourcePropType, ImageStyle as RNImageStyle, StyleProp } from 'react-native';
interface ImageStyle extends RNImageStyle {
    elevation?: number;
}
export interface ImageProps extends AccessibilityProps {
    source?: ImageSourcePropType | null;
    style?: StyleProp<ImageStyle>;
    resizeMode?: ImageResizeMode;
}
export default class Image extends React.Component<ImageProps> {
    render(): JSX.Element;
}
export {};
