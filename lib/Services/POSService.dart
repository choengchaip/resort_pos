import 'package:flutter/cupertino.dart';

class POSService extends ChangeNotifier {
  String posId;
  String posName;
  String permissionId;
  String color;
  String icon;
  int rowNumber;
  double width;
  String configEmail;

  void setPosId(posId) {
    this.posId = posId;
  }

  void setPosName(posName) {
    this.posName = posName;
  }

  void setPermissionId(permissionId) {
    this.permissionId = permissionId;
  }

  void setPosColor(color) {
    this.color = color;
  }

  void setPosIcon(icon) {
    this.icon = icon;
  }

  void setRowNumber(rowNumber) {
    this.rowNumber = rowNumber;
  }

  void setWidth(width) {
    this.width = width;
  }

  void setConfigEmail(email){
    this.configEmail = email;
  }

  String getPosId() {
    return this.posId;
  }

  String getPosName() {
    return this.posName;
  }

  String getPermissionId() {
    return this.permissionId;
  }

  String getPosColor() {
    return this.color;
  }

  String getPosIcon() {
    return this.icon;
  }

  int getRowNumber() {
    return this.rowNumber;
  }

  double getWidth() {
    return this.width;
  }

  String getConfigEmail(){
    return this.configEmail;
  }
}
