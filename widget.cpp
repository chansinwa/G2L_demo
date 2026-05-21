  #include "widget.h"

#include <QPainter>
#include <QPaintEvent>
#include <QResizeEvent>
#include <QtGlobal>

Widget::Widget(QWidget *parent)
    : QWidget(parent),
    image_(nullptr)
{
    setMinimumSize(320, 240);

//    connect(&timer_, &QTimer::timeout, this, [this]() {
//        angleDeg_ += 5.0f;
//        if (angleDeg_ >= 360.0f) {
//            angleDeg_ -= 360.0f;
//        }
//        update();
//    });

//    timer_.start(16);
}

Widget::~Widget()
{
    delete image_;
}
void Widget::resetView() {
    rotX = 0; rotY = 0; zoomZ = -8.0f;
    update();
}
void Widget::setupBuffers(int w, int h)
{
    framebuffer_.resize(w * h);
    zbuffer_.resize(w * h);
    delete image_;
    image_ = new tgx::Image<tgx::RGB565>(framebuffer_.data(), w, h);
}

void Widget::setupRenderer(int w, int h)
{
    renderer_.setViewportSize(w, h);
//    renderer_.setOffset(0, 0);
    renderer_.setImage(image_);
    renderer_.setZbuffer(zbuffer_.data());

    renderer_.setPerspective(45.0f, float(w) / float(h), 1.0f, 100.0f);

    // --material refllectionn --
    renderer_.setMaterial(tgx::RGBf(0.8f, 0.8f, 0.8f),// Material Base Color (Pure White)
                          0.7f, // Ambient: Base brightness in shadows
                          0.6f, // Diffuse: How much it reacts to direct light
                          1.0f, // Specular: High value for that "shiny" look (1.0f)
                        100); // Exponent: High value (80-100) makes the highlight small and sharp


    renderer_.setLookAt({0.0f, 0.0f, 8.0f}, {0.0f, 0.0f, 0.0f}, {0.0f, 0.0f, 0.0f});

    renderer_.setShaders(tgx::SHADER_GOURAUD | tgx::SHADER_TEXTURE);
}

void Widget::resizeEvent(QResizeEvent *event)
{
    QWidget::resizeEvent(event);

    const int w = qMax(1, width());
    const int h = qMax(1, height());

    setupBuffers(w, h);
    setupRenderer(w, h);
}

void Widget::renderFrame()
{
    if (!image_) {
        return;
    }

    image_->clear(tgx::RGB565_Cyan);
    renderer_.clearZbuffer();

    tgx::fMat4 model;
    model.setIdentity();

    //Apply transformations in order.
    // Note: TGX pre-multiplies, so the LAST command called is the FIRST applied.
    model.setTranslate(0.0f, 0.0f, 0.0f);

//    // Position and Zoom (Translation)
//    model.multTranslate(posX, posY, zoomZ);
    // Rotation around X (Up/Down)
    model.multRotate(rotX, 1.0f, 0.0f, 0.0f);
    // Rotation around Y (Left/Right)
    model.multRotate(rotY, 0.0f, 1.0f, 0.0f);
    // Scaling (Size)
    model.multScale(2.0f, 2.0f, 2.0f);
    // 4. Pass the matrix to the renderer
    renderer_.setModelMatrix(model);

    renderer_.setLookAt({0.0f, 0.0f, -zoomZ}, {0.0f, 0.0f, 0.0f}, {0.0f, 1.0f, 0.0f});
    // 5. Draw the mesh
    renderer_.drawMesh(&coffee_low_1, false);
}

//QRgb Widget::rgb565ToQrgb(const tgx::RGB565 &c) const
//{
//    return qRgb(c.R * 255 / 31,
//                c.G * 255 / 63,
//                c.B * 255 / 31);
//}

void Widget::paintEvent(QPaintEvent *event)
{
    Q_UNUSED(event);

    if (!image_) {
        return;
    }

    renderFrame();

    QImage img((uchar*)framebuffer_.data(), width(), height(), QImage::Format_RGB16);

    QPainter painter(this);
    painter.drawImage(rect(), img);
}

void Widget::mousePressEvent(QMouseEvent *event){
    lastMousePos = event->pos();
}

void Widget::mouseMoveEvent(QMouseEvent *event) {
    int dx = event->x() - lastMousePos.x();
    int dy = event->y() - lastMousePos.y();

    if (event->buttons() & Qt::LeftButton) {
        // Rotate: adjust sensitivity by dividing (e.g., / 2.0f)
        rotY += dx * 0.5f;
        rotX += dy * 0.5f;
    } else if (event->buttons() & Qt::RightButton) {
        // Move: adjust sensitivity
        posX += dx * 0.01f;
        posY -= dy * 0.01f; // Y is inverted in screen coords
    }

    lastMousePos = event->pos();
    update(); // Trigger a redraw immediately
}

void Widget::wheelEvent(QWheelEvent *event) {
    float delta = event->angleDelta().y() / 120.0f;
    zoomZ += delta * 0.5f; // Zoom in/out
    update();
}
