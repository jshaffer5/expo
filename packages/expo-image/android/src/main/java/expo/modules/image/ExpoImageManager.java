package expo.modules.image;

import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestManager;
import com.bumptech.glide.request.RequestOptions;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.JSApplicationIllegalArgumentException;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.annotations.ReactPropGroup;
import com.facebook.react.uimanager.ViewProps;
import com.facebook.yoga.YogaConstants;

import com.facebook.react.uimanager.PixelUtil;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class ExpoImageManager extends SimpleViewManager<ImageView> {
  private static final String REACT_CLASS = "ExpoImage";

  private static final String SOURCE_URI_KEY = "uri";
  private static final String SOURCE_WIDTH_KEY = "width";
  private static final String SOURCE_HEIGHT_KEY = "height";
  private static final String SOURCE_SCALE_KEY = "scale";

  private RequestManager mRequestManager;

  public ExpoImageManager(ReactApplicationContext applicationContext) {
    mRequestManager = Glide.with(applicationContext);
  }

  @NonNull
  @Override
  public String getName() {
    return REACT_CLASS;
  }

  // Props setters

  @ReactProp(name = "source")
  public void setSource(ImageView view, @Nullable ReadableMap sourceMap) {
    if (sourceMap == null || sourceMap.getString(SOURCE_URI_KEY) == null) {
      mRequestManager.clear(view);
      view.setImageDrawable(null);
      return;
    }

    RequestOptions options = new RequestOptions();

    // Override the size for local assets. This ensures that
    // resizeMode "center" displays the image in the correct size.
    if (sourceMap.hasKey(SOURCE_WIDTH_KEY) && sourceMap.hasKey(SOURCE_HEIGHT_KEY) && sourceMap.hasKey(SOURCE_SCALE_KEY)) {
      double scale = sourceMap.getDouble(SOURCE_SCALE_KEY);
      int width = sourceMap.getInt(SOURCE_WIDTH_KEY);
      int height = sourceMap.getInt(SOURCE_HEIGHT_KEY);
      options.override((int) (width * scale), (int) (height * scale));
    }

    options.fitCenter();

    mRequestManager
            .load(sourceMap.getString(SOURCE_URI_KEY))
            .apply(options)
            .into(view);
  }

  @ReactProp(name = "resizeMode")
  public void setResizeMode(ImageView view, String stringValue) {
    ExpoImageResizeMode resizeMode = ExpoImageResizeMode.fromStringValue(stringValue);
    if (resizeMode == ExpoImageResizeMode.UNKNOWN) {
      throw new JSApplicationIllegalArgumentException("Invalid resizeMode: " + stringValue);
    }
    view.setScaleType(resizeMode.getScaleType());
    // TODO: repeat mode handling
  }

  @ReactProp(name = "elevation")
  public void setElevation(@NonNull ExpoImageView view, float elevation) {
    view.setElevation(PixelUtil.toPixelFromDIP(elevation));
  }

  @ReactPropGroup(
          names = {
                  ViewProps.BORDER_RADIUS,
                  ViewProps.BORDER_TOP_LEFT_RADIUS,
                  ViewProps.BORDER_TOP_RIGHT_RADIUS,
                  ViewProps.BORDER_BOTTOM_RIGHT_RADIUS,
                  ViewProps.BORDER_BOTTOM_LEFT_RADIUS,
                  ViewProps.BORDER_TOP_START_RADIUS,
                  ViewProps.BORDER_TOP_END_RADIUS,
                  ViewProps.BORDER_BOTTOM_START_RADIUS,
                  ViewProps.BORDER_BOTTOM_END_RADIUS,
          },
          defaultFloat = YogaConstants.UNDEFINED)
  public void setBorderRadius(ExpoImageView view, int index, float borderRadius) {
    if (!YogaConstants.isUndefined(borderRadius) && borderRadius < 0) {
      borderRadius = YogaConstants.UNDEFINED;
    }
    view.setBorderRadius(borderRadius, index);
  }

  /*@ReactProp(name = "borderStyle")
  public void setBorderStyle(ExpoImageView view, @Nullable String borderStyle) {
    view.setBorderStyle(borderStyle);
  }*/

  @ReactPropGroup(
          names = {
                  ViewProps.BORDER_WIDTH,
                  ViewProps.BORDER_LEFT_WIDTH,
                  ViewProps.BORDER_RIGHT_WIDTH,
                  ViewProps.BORDER_TOP_WIDTH,
                  ViewProps.BORDER_BOTTOM_WIDTH,
                  ViewProps.BORDER_START_WIDTH,
                  ViewProps.BORDER_END_WIDTH,
          },
          defaultFloat = YogaConstants.UNDEFINED)
  public void setBorderWidth(ExpoImageView view, int index, float width) {
    /*if (!YogaConstants.isUndefined(width) && width < 0) {
      width = YogaConstants.UNDEFINED;
    }

    if (!YogaConstants.isUndefined(width)) {
      width = PixelUtil.toPixelFromDIP(width);
    }

    view.setBorderWidth(SPACING_TYPES[index], width);*/
  }

  @ReactPropGroup(
          names = {
                  ViewProps.BORDER_COLOR,
                  ViewProps.BORDER_LEFT_COLOR,
                  ViewProps.BORDER_RIGHT_COLOR,
                  ViewProps.BORDER_TOP_COLOR,
                  ViewProps.BORDER_BOTTOM_COLOR,
                  ViewProps.BORDER_START_COLOR,
                  ViewProps.BORDER_END_COLOR
          },
          customType = "Color")
  public void setBorderColor(ExpoImageView view, int index, Integer color) {
    /*float rgbComponent =
            color == null ? YogaConstants.UNDEFINED : (float) ((int) color & 0x00FFFFFF);
    float alphaComponent = color == null ? YogaConstants.UNDEFINED : (float) ((int) color >>> 24);
    view.setBorderColor(SPACING_TYPES[index], rgbComponent, alphaComponent);*/
  }

  // View lifecycle

  @NonNull
  @Override
  public ImageView createViewInstance(@NonNull ThemedReactContext context) {
    ExpoImageView imageView = new ExpoImageView(context);
    imageView.setScaleType(ExpoImageResizeMode.COVER.getScaleType());
    return imageView;
  }

  @Override
  public void onDropViewInstance(@NonNull ImageView view) {
    mRequestManager.clear(view);
    super.onDropViewInstance(view);
  }
}
