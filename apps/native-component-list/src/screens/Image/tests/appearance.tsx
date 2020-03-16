import { images } from '../images';
import { ImageTestGroup, ImageTestPropsFnInput } from '../types';
import { tintColor, tintColor2 } from './constants';

const imageTests: ImageTestGroup = {
  name: 'Appearance',
  tests: [
    {
      name: 'Plain',
      props: {},
    },
    {
      name: `Resize mode: cover`,
      props: {
        resizeMode: 'cover',
      },
    },
    {
      name: `Resize mode: contain`,
      props: {
        resizeMode: 'contain',
      },
    },
    {
      name: `Resize mode: stretch`,
      props: {
        resizeMode: 'stretch',
      },
    },
    {
      name: `Resize mode: center`,
      props: {
        resizeMode: 'center',
      },
    },
    {
      name: `Resize mode: repeat`,
      props: {
        resizeMode: 'repeat',
      },
    },
    {
      name: 'Blur radius',
      props: ({ range }: ImageTestPropsFnInput) => ({
        blurRadius: range(0, 60),
      }),
    },
    {
      name: 'Border color',
      props: {
        style: {
          borderWidth: 5,
          borderColor: tintColor,
        },
      },
    },
    {
      name: 'Border width',
      props: ({ range }: ImageTestPropsFnInput) => ({
        style: {
          borderWidth: range(0, 20),
          borderColor: tintColor,
        },
      }),
    },
    {
      name: 'Border style: Dotted',
      props: ({ range }: ImageTestPropsFnInput) => ({
        style: {
          borderWidth: range(0, 50),
          borderColor: tintColor,
          borderStyle: 'dotted',
        },
      }),
    },
    {
      name: 'Border style: Dashed',
      props: ({ range }: ImageTestPropsFnInput) => ({
        style: {
          borderWidth: range(0, 50),
          borderColor: tintColor,
          borderStyle: 'dashed',
        },
      }),
    },
    {
      name: 'Border style: Dotted & rounded',
      props: ({ range }: ImageTestPropsFnInput) => ({
        style: {
          borderWidth: range(0, 50),
          borderColor: tintColor,
          borderStyle: 'dotted',
          borderRadius: range(0, 50),
        },
      }),
    },
    {
      name: 'Border style: Dashed & rounded',
      props: ({ range }: ImageTestPropsFnInput) => ({
        style: {
          borderWidth: range(0, 50),
          borderColor: tintColor,
          borderStyle: 'dashed',
          borderRadius: range(0, 50),
        },
      }),
    },
    {
      name: 'Border radius',
      props: ({ range }: ImageTestPropsFnInput) => ({
        source: images.require_jpg1,
        style: {
          borderRadius: range(0, 200),
          borderWidth: 10,
          borderColor: tintColor,
        },
      }),
    },
    {
      name: 'Border radius: separate corners',
      props: ({ range }: ImageTestPropsFnInput) => ({
        source: images.require_jpg1,
        style: {
          borderTopLeftRadius: range(0, 25),
          borderTopRightRadius: range(0, 50),
          borderBottomLeftRadius: range(0, 75),
          borderBottomRightRadius: range(0, 200),
          borderWidth: 5,
          borderColor: tintColor,
        },
      }),
    },
    {
      name: 'Borders: separate edges',
      props: ({ range }: ImageTestPropsFnInput) => ({
        style: {
          borderLeftWidth: range(0, 25),
          borderLeftColor: tintColor,
          borderTopWidth: range(0, 25),
          borderTopColor: tintColor2,
          borderRightWidth: range(0, 25),
          borderRightColor: tintColor,
          borderBottomWidth: range(0, 25),
          borderBottomColor: tintColor2,
        },
      }),
    },

    {
      name: 'Opacity',
      props: ({ range }: ImageTestPropsFnInput) => ({
        style: {
          opacity: range(0, 1),
        },
      }),
    },
    {
      name: 'Tint color',
      props: {
        style: {
          tintColor,
        },
      },
    },
    {
      name: 'Background color',
      props: {
        style: {
          backgroundColor: tintColor,
        },
      },
    },
    {
      name: 'Shadow',
      props: ({ range }: ImageTestPropsFnInput) => ({
        style: {
          shadowColor: '#000',
          shadowOffset: {
            width: 0,
            height: range(2, 5),
          },
          shadowOpacity: range(0.2, 0.5),
          shadowRadius: range(0, 10),
          elevation: range(0, 10),
        },
      }),
    },
    {
      name: 'Shadow: and border-radius',
      props: ({ range }: ImageTestPropsFnInput) => ({
        style: {
          borderRadius: range(0, 100),
          shadowColor: '#000',
          shadowOffset: {
            width: 0,
            height: range(2, 5),
          },
          shadowOpacity: range(0.2, 0.5),
          shadowRadius: range(0, 10),
          elevation: range(0, 10),
        },
      }),
    },
    {
      name: 'Shadow: and separate border-radius',
      props: ({ range }: ImageTestPropsFnInput) => ({
        style: {
          borderTopLeftRadius: range(0, 25),
          borderTopRightRadius: range(0, 50),
          borderBottomLeftRadius: range(0, 75),
          borderBottomRightRadius: range(0, 200),
          shadowColor: '#000',
          shadowOffset: {
            width: 0,
            height: 5,
          },
          shadowOpacity: 0.5,
          shadowRadius: 10,
          elevation: 10,
        },
      }),
    },
  ],
};

export default imageTests;
