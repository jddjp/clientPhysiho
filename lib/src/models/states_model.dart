// @dart=2.9

class States {
  bool error;
  int codeError;
  dynamic errorMessage;
  Response response;

  States({
    this.error,
    this.codeError,
    this.errorMessage,
    this.response,
  });
}

class Response {
  List<String> estado;

  Response({
    this.estado,
  });
}
