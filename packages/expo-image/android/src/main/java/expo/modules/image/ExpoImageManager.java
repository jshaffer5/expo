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

  // View lifecycle

  @NonNull
  @Override
  public ImageView createViewInstance(@NonNull ThemedReactContext context) {
    ImageView imageView = new ImageView(context);
    imageView.setScaleType(ExpoImageResizeMode.COVER.getScaleType());
    return imageView;
  }

  @Override
  public void onDropViewInstance(@NonNull ImageView view) {
    mRequestManager.clear(view);
    super.onDropViewInstance(view);
  }
}
