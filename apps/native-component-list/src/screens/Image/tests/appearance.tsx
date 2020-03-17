import { ImageTestGroup, ImageTestPropsFnInput } from '../types';
import { tintColor } from './constants';

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
