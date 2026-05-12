  #include "widget.h"

#include <QPainter>
#include <QPaintEvent>
#include <QResizeEvent>
#include <QtGlobal>

Widget::Widget(QWidget *parent)
    : QWidget(parent),
    image_(nullptr),
    angleDeg_(0.0f)
{
    setMinimumSize(320, 240);

    connect(&timer_, &QTimer::timeout, this, [this]() {
        angleDeg_ += 5.0f;
        if (angleDeg_ >= 360.0f) {
            angleDeg_ -= 360.0f;
        }
        update();
    });

    timer_.start(16);
}

Widget::~Widget()
{
    delete image_;
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
    renderer_.setOffset(0, 0);
    renderer_.setImage(image_);
    renderer_.setZbuffer(zbuffer_.data());

    renderer_.setPerspective(45.0f, float(w) / float(h), 1.0f, 100.0f);
    renderer_.setMaterial(tgx::RGBf(0.85f, 0.55f, 0.25f), 0.2f, 0.7f, 0.8f, 64);
    renderer_.setCulling(1);
    renderer_.setTextureQuality(tgx::SHADER_TEXTURE_NEAREST);
    renderer_.setTextureWrappingMode(tgx::SHADER_TEXTURE_WRAP_POW2);
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

    renderer_.setModelPosScaleRot(
        {0.0f, 0.0f, -8.0f},
        {2.0f, 2.0f, 2.0f},
        angleDeg_
        );

    renderer_.drawMesh(&coffee_cup_1, false);
}

QRgb Widget::rgb565ToQrgb(const tgx::RGB565 &c) const
{
    return qRgb(c.R * 255 / 31,
                c.G * 255 / 63,
                c.B * 255 / 31);
}

void Widget::paintEvent(QPaintEvent *event)
{
    Q_UNUSED(event);

    if (!image_) {
        return;
    }

    renderFrame();

    QImage img(width(), height(), QImage::Format_RGB32);
    for (int y = 0; y < height(); ++y) {
        QRgb *line = reinterpret_cast<QRgb *>(img.scanLine(y));
        for (int x = 0; x < width(); ++x) {
            line[x] = rgb565ToQrgb(framebuffer_[y * width() + x]);
        }
    }

    QPainter painter(this);
    painter.drawImage(rect(), img);
}
