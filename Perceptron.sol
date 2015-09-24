contract Perceptron {
    int256[][] public training_data;
    bool[] public target_decisions;
    int256[] public weights;
    int256 public threshold = 0;
    event Learning(int256, uint256);
    event Weights(string, int256);
    event Converged();

    function echo(int[] a, uint b) returns (int) {
        return a[b];
    }
    function dotProduct(int[] w,int[] x) returns (int ret) {
        /*
           dotProduct([1,2,3,4],[5,6,7,8]) => 70
         */

        ret = 0;
        for (uint i = 0; i < w.length; i++){
            int256 _w = w[i];
            int256 _x = x[i];
            ret += _w * _x;
        }
    }

    function array_is_equal(int256[] a, int256[] b) returns (bool) {
        /*
           Compares arrays for equality
         */
        if (a.length != b.length) {
            return false;
        }
        for(uint i=0; i< a.length; i++) {
            if (a[i] != b[i]) {
                return false;
            }
        }
        return true;
    }

    function decide(int[] data) returns (bool) {
        /*
           decide([1,2,3,4],[5,6,7,8]) => true
           decide([1,2,3,4],[5,6,7,8]) => false
         */

        int256 dp = 0;
        uint len = data.length;
        uint i = 0;
        for (i = 0; i < len; i++){
            dp = dp + (data[i] * weights[i]);
        }
        if (dp > threshold) {
            return true;
        }
        return false;
    }

    function addTrainingItem(int[] data, bool target) returns (int[]) {
        /*
           addTrainingItem([1], true);
           addTrainingItem([15], false);
         */

        // Is this existing training data?
        for (uint j = 0; j < training_data.length; j++) {
            if (array_is_equal(data, training_data[j])){
                // Yes, let's update the target
                target_decisions[j] = target;
                return weights;
            }
        }
        // the training data is new, so append it.
        training_data[training_data.length++] = data;
        target_decisions[target_decisions.length++] = target;
        weights.length = data.length;
        return weights;
    }

    function getTrainingItem(uint i) returns (int256[] data, bool target) {
        data = training_data[i];
        target = target_decisions[i];
    }

    function getWeights() returns (int256[]) {
        return weights;
    }

    function learn(uint max_iterations) returns (bool){
        uint converged = 0;
        int256 last_threshold = 0;
        int256[] memory last_weights;
        last_weights = weights;

        for (uint i = 0; i < max_iterations; i++) {
            learnOnce();
            Learning(threshold, converged);
            if (last_threshold == threshold && array_is_equal(last_weights, weights)) {
                converged++;
                if (converged == 3) {
                    // no change for three iterations
                    Converged();
                    return true;
                }
            } else {
                converged = 0;
            }

            last_threshold = threshold;
            last_weights = weights;
        }
        return false;
    }

    function learnOnce() returns (int256 ret){
        for (uint j = 0; j < training_data.length; j++) {
            int256[] memory data = training_data[j];
            bool target_decision = target_decisions[j];
            bool decision = decide(data);
            if (decision == target_decision) {
                // continue
            } else {
                if (decision == false
                        && target_decision == true) {
                    threshold -= 1;
                    for (var k = 0; k < data.length; k++) {
                        weights[k] += data[k];
                    }
                } else {
                    if (decision == true && target_decision == false) {
                        threshold += 1;
                        for (var l = 0; l < data.length; l++) {
                            weights[l] -= data[l];
                        }
                    }
                }
            }
        }
        ret = threshold;
    }
}
