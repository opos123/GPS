#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QSerialPort>
#include <QQmlApplicationEngine>
#include <QQmlContext>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void readSerialData();

signals:
    void coordinatesUpdated(double latitude, double longitude);

private:
    Ui::MainWindow *ui;
    QSerialPort *serialPort;
    QQmlApplicationEngine engine;
};

#endif // MAINWINDOW_H
