package expo.modules.image;

import android.content.Context;
import android.graphics.Canvas;
import android.widget.ImageView;

class ExpoImageView extends ImageView {
  private int mBackgroundColor;
  private ExpoImageOutlineProvider mOutlineProvider;

  public ExpoImageView(Context context) {
    super(context);
    mBackgroundColor = 0;
    //setLayerType(View.LAYER_TYPE_HARDWARE, null);
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

    /*
    @Override
    public boolean isOpaque () {
        return true;
    }*/

    /*
    @Override
    public boolean hasOverlappingRendering() {
        return false;
    }*/

  private void updateBackgroundColor() {
    int color = mBackgroundColor;
    float elevation = getElevation();
    if (elevation > 0) {
      if (color == 0) {
        color = 0xffffffff;
      }
    }
    super.setBackgroundColor(color);
  }

  public void setBorderRadius(float borderRadius, int position) {
    boolean isInvalidated = mOutlineProvider.setBorderRadius(borderRadius, position);
    if (isInvalidated) {
      invalidateOutline();
      if (!mOutlineProvider.hasEqualCorners()) {
        invalidate();
      }
    }
  }

  @Override
  public void draw(Canvas canvas) {
    mOutlineProvider.clipCanvasIfNeeded(canvas, this);
    super.draw(canvas);
  }
}