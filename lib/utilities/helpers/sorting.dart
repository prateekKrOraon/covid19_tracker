class SortingOrder{
  static const int CNF_DEC = 0;
  static const int CNF_INC = 1;
  static const int STATE_INC = 2;
  static const int STATE_DEC = 3;
  static const int ACTV_DEC = 4;
  static const int ACTV_INC = 5;
  static const int REC_DEC = 6;
  static const int REC_INC = 7;
  static const int DET_DEC = 8;
  static const int DET_INC = 9;

  int _order = CNF_DEC;

  bool checkOrder(int order){
    return _order == order;
  }

  setOrder(int order){
    _order = order;
  }

}