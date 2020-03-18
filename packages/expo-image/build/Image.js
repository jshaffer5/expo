import React from 'react';
import { StyleSheet, } from 'react-native';
import ExpoImage from './ExpoImage';
const DEFAULT_RESIZE_MODE = 'cover';
export default class Image extends React.Component {
    render() {
        const { style, resizeMode: resizeModeProp, ...restProps } = this.props;
        const { resizeMode: resizeModeStyle, ...restStyle } = StyleSheet.flatten([style]) || {};
        const resizeMode = resizeModeProp ?? resizeModeStyle ?? DEFAULT_RESIZE_MODE;
        return <ExpoImage {...restProps} style={restStyle} resizeMode={resizeMode}/>;
    }
}
//# sourceMappingURL=Image.js.map