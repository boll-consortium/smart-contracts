pragma solidity ^0.4.0;

contract ShikenMosi {
    address public owner;
    mapping (uint => bool) public all_years;
    struct Test {
        string type;
        uint score;
        uint standard_score;
        uint gtz;
    }
    struct Score {
        uint year;
        uint grade;
        Test [] tests;
        Test [] total;
    }
    address [] public schools;
    mapping (address => Score[]) public scores;

    function ShikenMosi(address _owner){
        owner = _owner;
    }

    function insertRecord(address school, uint year, uint grade, string type, uint score, uint standard_score, uint gtz,
        string t_type, uint t_score, uint t_standard_score, uint t_gtz) payable {
        if(msg.sender == owner || msg.sender == school) {
            if(scores[school] == false) {
                schools.push(school);
                scores[school] = Score [];
            }
            scores[school].push(Score(year, grade, Test(type, score, standard_score, gtz),
                Test(t_type, t_score, t_standard_score, t_gtz)));
        }
    }
}
