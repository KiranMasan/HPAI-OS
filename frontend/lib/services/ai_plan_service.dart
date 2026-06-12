import 'dart:convert';

import 'package:http/http.dart'
    as http;

import 'network_utils.dart';

class AIPlanService {

  static Future<String>
      generatePlan({

    required String goal,

    required String level,

    required String hours,

    required String target,
  }) async {

    final response =
        await http.post(

      Uri.parse(
        '${NetworkUtils.baseUrl}/generate-plan',
      ),

      headers: {
        "Content-Type":
            "application/json",
      },

      body: jsonEncode({

        "goal": goal,

        "level": level,

        "hours": hours,

        "target": target,
      }),
    );

    final data =
        jsonDecode(response.body);

    return data["plan"];
  }
}