class UpdateServerPasses{
  DateTime _currentDate;
  updateServerPasses(){
    _currentDate = DateTime.now();
  }
  bool equalDate(DateTime obj){
    if (_currentDate.month == obj.month && _currentDate.year == obj.year){
      return true;
    } return false;
  }
}
