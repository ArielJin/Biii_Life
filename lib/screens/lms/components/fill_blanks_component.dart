import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/main.dart';
import 'package:Biii_Life/models/lms/quiz_model.dart';
import 'package:Biii_Life/utils/app_constants.dart';

class FillBlanksComponent extends StatefulWidget {
  final List<Option> options;
  final QuestionAnsweresModel? answered;
  final bool isReviewQuiz;
  final int quizId;
  final int questionId;

  const FillBlanksComponent({required this.options, this.answered, required this.isReviewQuiz, required this.quizId, required this.questionId});

  @override
  State<FillBlanksComponent> createState() => _FillBlanksComponentState();
}

class _FillBlanksComponentState extends State<FillBlanksComponent> {
  List<OptionAnswer> answer = [];

  TextEditingController ans = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isReviewQuiz && widget.answered != null) {
      log(widget.answered!.options.validate().length);
      widget.answered!.options.validate().forEach((element) {
        log(element.answers);
      });
    } else if (lmsStore.quizList.isNotEmpty) {
      int index = lmsStore.quizList.indexWhere((element) => element.quizId == widget.quizId);

      int x = lmsStore.quizList[index].answers.validate().indexWhere((element) => element.questionId.validate().toInt() == widget.questionId);

      if (lmsStore.quizList[index].answers.validate()[x].value.validate().isNotEmpty) {
        ans.text = lmsStore.quizList[index].answers.validate()[x].value.validate();
        setState(() {});
      }
    }

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (ctx, i) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isReviewQuiz)
              Offstage()
            else
              AppTextField(
                controller: ans,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
                textFieldType: TextFieldType.NAME,
                textStyle: primaryTextStyle(),
                maxLines: 1,
                decoration: inputDecorationFilled(context, fillColor: context.scaffoldBackgroundColor),
                onFieldSubmitted: (text) {
                  if (lmsStore.quizList.isNotEmpty) {
                    int index = lmsStore.quizList.indexWhere((element) => element.quizId == widget.quizId);

                    int x = lmsStore.quizList[index].answers.validate().indexWhere((element) => element.questionId.validate().toInt() == widget.questionId);
                    lmsStore.quizList[index].answers.validate()[x].value = text;
                    setValue(SharePreferencesKey.LMS_QUIZ_LIST, jsonEncode(lmsStore.quizList));
                  }
                },
              ),
            8.height,
          ],
        ).paddingSymmetric(vertical: 8);
      },
      itemCount: widget.options.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }
}
