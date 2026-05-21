
#include <QApplication>
#include "coffeeviewer.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    CoffeeViewer viewer;
    viewer.setWindowTitle("Coffee Brewing");
//    viewer.showFullScreen();
    viewer.resize(1000,400);
    viewer.show();

    return app.exec();
}
