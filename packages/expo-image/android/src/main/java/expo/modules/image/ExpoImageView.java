package expo.modules.image;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.modules.i18nmanager.I18nUtil;
import com.facebook.react.uimanager.PixelUtil;
import com.facebook.yoga.YogaConstants;

class ExpoImageView extends ImageView {
  private int mBackgroundColor;
  private ExpoImageOutlineProvider mOutlineProvider;
  private ExpoImageBorderDrawable mBorderDrawable;

  public ExpoImageView(Context context) {
    super(context);
    mBackgroundColor = 0;
    super.setBackgroundColor(mBackgroundColor);
    mOutlineProvider = new ExpoImageOutlineProvider(context);
    setOutlineProvider(mOutlineProvider);
    setClipToOutline(true);
  }

  @Override
  public void setBackgroundColor(int color) {
    mBackgroundColor = color;
    updateBackgroundColor();
  }

  @Override
  public void setElevation(float elevation) {
    super.setElevation(elevation);
    updateBackgroundColor();
  }

  private void updateBackgroundColor() {
    // Shadows are not masked to the outside of the outline, but are
    // partially visible on the inside as well. It doesn't seem possible
    // to mask the shadows without reverting to sofware rendering of the shadows.
    // As a workaround, the background-color is therefore set to opaque white when
    // elevation is used and no background color is specified.
    int backgroundColor = ((getElevation() > 0) && (mBackgroundColor == 0)) ? 0xffffffff : mBackgroundColor;
    super.setBackgroundColor(backgroundColor);
  }

  public void setBorderRadius(int position, float borderRadius) {
    boolean isInvalidated = mOutlineProvider.setBorderRadius(borderRadius, position);
    if (isInvalidated) {
      invalidateOutline();
      if (!mOutlineProvider.hasEqualCorners()) {
        invalidate();
      }
    }

    // Setting the border-radius doesn't necessarily mean that a border
    // should to be drawn. Only update the border-drawable when needed.
    if (mBorderDrawable != null) {
      borderRadius = !YogaConstants.isUndefined(borderRadius) ? PixelUtil.toPixelFromDIP(borderRadius) : borderRadius;
      if (position == 0) {
        mBorderDrawable.setRadius(borderRadius);
      } else {
        mBorderDrawable.setRadius(borderRadius, position - 1);
      }
    }
  }

  private ExpoImageBorderDrawable getOrCreateBorderDrawable() {
    if (mBorderDrawable == null) {
      mBorderDrawable = new ExpoImageBorderDrawable(getContext());
      mBorderDrawable.setCallback(this);
      float[] borderRadii = mOutlineProvider.getBorderRadii();
      for (int i = 0; i < borderRadii.length; i++) {
        float borderRadius = borderRadii[i];
        borderRadius = !YogaConstants.isUndefined(borderRadius) ? PixelUtil.toPixelFromDIP(borderRadius) : borderRadius;
        if (i == 0) {
          mBorderDrawable.setRadius(borderRadius);
        } else {
          mBorderDrawable.setRadius(borderRadius, i - 1);
        }
      }
    }
    return mBorderDrawable;
  }

  @Override
  public void invalidateDrawable(@NonNull Drawable dr) {
    super.invalidateDrawable(dr);
    if (dr == mBorderDrawable) {
      invalidate();
    }
  }

  public void setBorderWidth(int position, float width) {
    getOrCreateBorderDrawable().setBorderWidth(position, width);
  }

  public void setBorderColor(int position, float rgb, float alpha) {
    getOrCreateBorderDrawable().setBorderColor(position, rgb, alpha);
  }

  public void setBorderStyle(@Nullable String style) {
    getOrCreateBorderDrawable().setBorderStyle(style);
  }

  @Override
  public void draw(Canvas canvas) {
    mOutlineProvider.clipCanvasIfNeeded(canvas, this);
    super.draw(canvas);
  }

  @Override
  public void onDraw(Canvas canvas) {
    super.onDraw(canvas);

    // Draw borders on top of the background and image
    if (mBorderDrawable != null) {
      int layoutDirection = I18nUtil.getInstance().isRTL(getContext())
              ? LAYOUT_DIRECTION_RTL
              : LAYOUT_DIRECTION_LTR;
      mBorderDrawable.setResolvedLayoutDirection(layoutDirection);
      mBorderDrawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
      mBorderDrawable.draw(canvas);
    }
  }
}