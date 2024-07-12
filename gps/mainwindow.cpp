#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QSerialPortInfo>
#include <QMessageBox>
#include <QDebug>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , serialPort(new QSerialPort(this))
{
    ui->setupUi(this);

    // Set serial port name and open it
    serialPort->setPortName("COM7"); // Ganti dengan nama port Arduino Anda
    serialPort->setBaudRate(QSerialPort::Baud115200); // Sesuaikan dengan baud rate Arduino Anda

    if (!serialPort->open(QIODevice::ReadOnly)) {
        QMessageBox::critical(this, "Error", serialPort->errorString());
        return;
    }

    connect(serialPort, &QSerialPort::readyRead, this, &MainWindow::readSerialData);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    engine.rootContext()->setContextProperty("mainWindow", this);

    if (engine.rootObjects().isEmpty()) {
        QMessageBox::critical(this, "Error", "Failed to load QML file.");
        return;
    }
}

MainWindow::~MainWindow()
{
    delete ui;
    if (serialPort->isOpen())
        serialPort->close();
}

void MainWindow::readSerialData()
{
    while (serialPort->canReadLine()) {
        QByteArray data = serialPort->readLine();
        ui->textEdit->append(data); // Tampilkan data di QTextEdit

        QList<QByteArray> coords = data.split(',');
        if (coords.size() == 2) {
            double lat = coords[0].trimmed().toDouble();
            double lng = coords[1].trimmed().toDouble();
            emit coordinatesUpdated(lat, lng);
        }
    }
}
