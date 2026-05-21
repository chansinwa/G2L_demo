#ifndef COFFEEVIEWER_H
#define COFFEEVIEWER_H

#include <QWidget>
#include <QMediaPlayer>
#include <QVideoWidget>
#include <QQuickWidget> //for hardware 3d handling
#include "widget.h"

class CoffeeViewer : public QWidget {
    Q_OBJECT

public:
    explicit CoffeeViewer(QWidget *parent = nullptr);

private:
    // Widget *m_3dWidget; //commented out TGX
    QQuickWidget *m_3dQuickWidget;
    QMediaPlayer* m_player;
    QVideoWidget* m_videoWidget;
};
#endif
