class TimedSubject {
  final String name;
  final String code;
  final String roomCode;
  late final String roomLevel;
  final bool online;
  final DateTime startTime;
  final DateTime endTime;
  int followingDay;
  bool followingWeek;

  TimedSubject({
    required this.name,
    required this.code,
    required this.roomCode,
    required this.online,
    required this.startTime,
    required this.endTime,
    this.followingWeek = false,
    this.followingDay = 0,
  }) {
    if (roomCode.length == 3) {
      roomLevel = roomCode.substring(0, 1);
    } else {
      roomLevel = roomCode.substring(0, 2);
    }
  }

  factory TimedSubject.empty() {
    return TimedSubject(
      name: "Placeholder Name",
      code: "XXX0000",
      roomCode: "1801",
      online: true,
      startTime: DateTime(1970),
      endTime: DateTime(1970),
    );
  }

  String getFormattedDuration([bool markdown = false]) {
    if (followingDay > 0) {
      if (followingDay == 1) {
        return "starts in 1 day";
      }
      return "starts in $followingDay days";
    }

    if (followingWeek) {
      return "starts next week";
    }

    String formattedDuration = "";

    Duration rawDuration;
    if (!hasStarted()) {
      formattedDuration += "starts in ";
      rawDuration = startTime.difference(DateTime.now());
    } else {
      if (isOngoing()) {
        formattedDuration += "ends in ";
      } else {
        formattedDuration += "ended ";
      }
      rawDuration = endTime.difference(DateTime.now());
    }
    int rawDurationMinutes = rawDuration.inMinutes;

    if (rawDurationMinutes > 0) {
      if (markdown) {
        formattedDuration += "**";
      }
      int durationHours = (rawDurationMinutes / 60).floor();
      int durationMinutes = (rawDurationMinutes % 60).floor();
      if (durationHours > 0) {
        formattedDuration += "$durationHours ";
        if (durationHours > 1) {
          formattedDuration += "hours ";
        } else {
          formattedDuration += "hour ";
        }
      }
      if (durationMinutes > 0) {
        if (durationHours > 0) {
          formattedDuration += "and ";
        }
        formattedDuration += "$durationMinutes ";
        if (durationMinutes > 1) {
          formattedDuration += "minutes ";
        } else {
          formattedDuration += "minute ";
        }
      }
      formattedDuration += "from now";
      if (markdown) {
        formattedDuration += "**";
      }
    } else {
      if (markdown) {
        formattedDuration += "**";
      }
      int durationHours = (rawDurationMinutes / 60).ceil().abs();
      int durationMinutes = (rawDurationMinutes % -60).ceil().abs();
      if (durationHours > 0) {
        formattedDuration += "$durationHours ";
        if (durationHours > 1) {
          formattedDuration += "hours ";
        } else {
          formattedDuration += "hour ";
        }
      }
      if (durationMinutes > 0) {
        if (durationHours > 0) {
          formattedDuration += "and ";
        }
        formattedDuration += "$durationMinutes ";
        if (durationMinutes > 1) {
          formattedDuration += "minutes ";
        } else {
          formattedDuration += "minute ";
        }
      }
      formattedDuration += "ago";
      if (markdown) {
        formattedDuration += "**";
      }
    }
    return formattedDuration;
  }

  bool hasStarted() {
    return startTime.isBefore(DateTime.now());
  }

  bool hasFinished() {
    return endTime.isBefore(DateTime.now());
  }

  bool isOngoing() {
    return hasStarted() && !hasFinished();
  }
}
