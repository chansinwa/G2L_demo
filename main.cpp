
#include <QApplication>
#include "coffeeviewer.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    CoffeeViewer viewer;
    viewer.setWindowTitle("Coffee Brewing");
    viewer.showFullScreen();
    // viewer.resize(1280,480);
    // viewer.show();

    return app.exec();
}
