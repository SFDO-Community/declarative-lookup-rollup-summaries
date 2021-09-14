({
    doInit : function(cmp) {
        // Calls OptimizerService.analyze
        var action = cmp.get("c.analyze");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.summary', response.getReturnValue());
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }            
        });
        $A.enqueueAction(action);
    }
})
