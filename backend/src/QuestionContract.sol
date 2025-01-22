// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract QuestionAndAnswer {
    struct Question {
        uint256 questionId;
        string content;
        address asker;
        uint256 timestamp;
        bool isResolved;
        bool exists;
    }

    struct Answer {
        uint256 answerId;
        uint256 questionId;
        string content;
        address responder;
        uint256 timestamp;
        bool exists;
    }

    mapping(uint256 => Question) public questions;
    mapping(uint256 => Answer[]) public questionAnswers;

    uint256 private _questionIds;
    uint256 private _answerIds;

    function askQuestion(string memory content) public returns (uint256) {
        require(bytes(content).length > 0, "Content cannot be empty");

        _questionIds++;
        uint256 newQuestionId = _questionIds;

        questions[newQuestionId] = Question({
            questionId: newQuestionId,
            content: content,
            asker: msg.sender,
            timestamp: block.timestamp,
            isResolved: false,
            exists: true
        });

        return newQuestionId;
    }
    function submitAnswer(uint256 questionId, string memory content) public {
        require(questions[questionId].exists, "Question does not exist");
        require(
            !questions[questionId].isResolved,
            "Question is already resolved"
        );
        require(bytes(content).length > 0, "Content cannot be empty");

        _answerIds++;
        questionAnswers[questionId].push(
            Answer({
                answerId: _answerIds,
                questionId: questionId,
                content: content,
                responder: msg.sender,
                timestamp: block.timestamp,
                exists: true
            })
        );
    }

    function resolveQuestion(uint256 questionId) public {
        require(questions[questionId].exists, "Question does not exist");
        require(questions[questionId].asker == msg.sender, "Not the asker");
        require(!questions[questionId].isResolved, "Already resolved");

        questions[questionId].isResolved = true;
    }

    function getAllQuestions() public view returns (Question[] memory) {
        uint256 count = _questionIds;
        Question[] memory allQuestions = new Question[](count);

        for (uint256 i = 1; i <= count; i++) {
            allQuestions[i - 1] = questions[i];
        }

        return allQuestions;
    }

    function getAnswers(
        uint256 questionId
    ) public view returns (Answer[] memory) {
        return questionAnswers[questionId];
    }
}
