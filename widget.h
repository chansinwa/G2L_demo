
#ifndef WIDGET_H
#define WIDGET_H

#include <QWidget>
#include <QTimer>
#include <vector>

#include "src/tgx.h"
#include "model/coffee_cup.h"

class Widget : public QWidget
{
    Q_OBJECT

public:
    explicit Widget(QWidget *parent = nullptr);
    ~Widget() override;

protected:
    void paintEvent(QPaintEvent *event) override;
    void resizeEvent(QResizeEvent *event) override;

private:
    void setupBuffers(int w, int h);
    void setupRenderer(int w, int h);
    void renderFrame();
    QRgb rgb565ToQrgb(const tgx::RGB565 &c) const;

    std::vector<tgx::RGB565> framebuffer_;
    std::vector<float> zbuffer_;
    tgx::Image<tgx::RGB565> *image_;
    tgx::Renderer3D<tgx::RGB565> renderer_;
    QTimer timer_;
    float angleDeg_;
};

#endif
