#include "coffeeviewer.h"
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QPushButton>
#include <QLabel>
#include <QFrame>
#include <QStackedWidget>
#include <QApplication>
#include <QQmlContext>
#include <QQuickItem>

CoffeeViewer::CoffeeViewer(QWidget *parent) : QWidget(parent) {
    QHBoxLayout *mainLayout = new QHBoxLayout(this);

    QStackedWidget *stackedWidget = new QStackedWidget(this);

    m_player = new QMediaPlayer(this);
    m_videoWidget = new QVideoWidget(this);
    m_player->setVideoOutput(m_videoWidget);
    QString videoPath = QCoreApplication::applicationDirPath() + "/media/brew-coffee-resize.mp4";

    // m_player->setSource(QUrl::fromLocalFile(videoPath));

    // --- NEW HARDWARE 3D SETUP ---
    m_3dQuickWidget = new QQuickWidget(this);
    m_3dQuickWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);
    m_3dQuickWidget->setSource(QUrl::fromLocalFile(QCoreApplication::applicationDirPath() + "/coffee_scene.qml"));

    // 1. The 3D View (Left Side)
    // m_3dWidget = new Widget(this);

    stackedWidget->addWidget(m_3dQuickWidget); //index 0
    stackedWidget->addWidget(m_videoWidget); //index 1

    mainLayout->addWidget(stackedWidget, 4); // Stretch factor 4

    // 2. The Sidebar (Right Side)
    QFrame *sidebar = new QFrame(this);
    sidebar->setFixedWidth(180);
    sidebar->setStyleSheet("background-color: #2c3e50; color: white; border-radius: 10px;");

    QVBoxLayout *sideLayout = new QVBoxLayout(sidebar);

    QLabel *lblTitle = new QLabel("Product View", this);
    lblTitle->setStyleSheet("font-size: 18px; font-weight: bold; margin: 10px;");

//    QLabel *beanStrength = new QLabel("Bean Strength: 4", this);
//    QLabel *grindingLevel = new QLabel("Grinding Level: 5", this);
//    QLabel *quantity = new QLabel("Quantity: 220ml", this);
//    QLabel *contactTime = new QLabel("Contact Time: 35s", this);

//    QString brewInfo = "QLabel {background: #65a9ad; border: 1px; padding: 12px; color: white; border-radius: 5px; font-weight: bold;}";
//    beanStrength->setStyleSheet(brewInfo);
//    grindingLevel->setStyleSheet(brewInfo);
//    quantity->setStyleSheet(brewInfo);
//    contactTime->setStyleSheet(brewInfo);;

    QPushButton *btnReset = new QPushButton("Reset Camera", this);
    QPushButton *btnVideo = new QPushButton("Play Video", this);
    QPushButton *btnExit = new QPushButton("Back", this);
    btnExit->hide();

    // Modern Button Styling
    QString style = "QPushButton { background: #3498db; border: none; padding: 12px; color: white; border-radius: 5px; font-weight: bold; }"
                    "QPushButton:hover { background: #2980b9; }";
    btnReset->setStyleSheet(style);
    btnVideo->setStyleSheet(style.replace("#3498db", "#f1c40f").replace("#2980b9", "#d4ac0d"));
    btnExit->setStyleSheet(style.replace("#3498db", "#e74c3c").replace("#2980b9", "#c0392b"));

    sideLayout->addWidget(lblTitle);
    sideLayout->addWidget(btnReset);
    sideLayout->addWidget(btnVideo);
    sideLayout->addStretch();
//    sideLayout->addWidget(beanStrength);
//    sideLayout->addWidget(grindingLevel);
//    sideLayout->addWidget(quantity);
//    sideLayout->addWidget(contactTime);
//    sideLayout->addStretch();
    sideLayout->addWidget(btnExit);
    mainLayout->addWidget(sidebar);

    // 3. Connect UI to 3D Widget
    connect(btnReset, &QPushButton::clicked, this, [=](){
        if (m_3dQuickWidget->rootObject()){
            QMetaObject::invokeMethod(m_3dQuickWidget->rootObject(), "resetCamera", Qt::QueuedConnection);
        }
    });

    connect(btnExit, &QPushButton::clicked, [=](){
        m_player->stop();
        stackedWidget->setCurrentIndex(0);
        btnExit->hide();
        btnVideo->show();
        btnReset->show();
    });

    connect(btnVideo, &QPushButton::clicked, this, [=](){
        stackedWidget->setCurrentIndex(1); // Show VideoWidget
        btnExit->show();
        btnVideo->hide();
        btnReset->hide();
        m_player->setSource(QUrl::fromLocalFile(videoPath));
        m_player->play();
    });

    // auto-return to 3d when video stops
    connect(m_player, &QMediaPlayer::playbackStateChanged, this, [=](QMediaPlayer::PlaybackState state){
        if(state == QMediaPlayer::StoppedState){
            stackedWidget->setCurrentIndex(0); //Show 3DWwidget again
            btnExit->hide();
            btnVideo->show();
            btnReset->show();
        }
    });
}
