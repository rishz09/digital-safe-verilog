`timescale 1ns / 1ps

module testbench;
reg [9:0]virtual_numpad = 10'b0000000000;
reg virtual_enter = 0, set_new_pass = 0, virtual_reset = 0, virtual_logout = 0, custom_clk = 0, sysclk = 0;
wire loggedin_led, loggedout_led, seto, locked_led, locked_led1, locked_led2, locked_led3, locked_led4;
wire [6:0]custom_state_display;
wire [3:0]enable;
wire [6:0]ssd;
wire [3:0]present_state;
//wire custom_clk;

digital_safe d1(.virtual_numpad(virtual_numpad),
.virtual_enter(virtual_enter),
.set_new_pass(set_new_pass),
.virtual_reset(virtual_reset),
.virtual_logout(virtual_logout),
.sysclk(sysclk),
.custom_clk(custom_clk),
.loggedin_led(loggedin_led),
.loggedout_led(loggedout_led),
.seto(seto),
.locked_led(locked_led),
.locked_led1(locked_led1),
.locked_led2(locked_led2),
.locked_led3(locked_led3),
.locked_led4(locked_led4),
.custom_state_display(custom_state_display),
.enable(enable),
.ssd(ssd),
.present_state(present_state));

always #0.0625 sysclk = ~ sysclk;
always #0.5 custom_clk = ~ custom_clk;

initial begin
    #3;
    //setting password for the first time
    virtual_numpad[1] = 1; #5;
    virtual_numpad[1] = 0; #3;
    virtual_numpad[2] = 1; #5;
    virtual_numpad[2] = 0; #3;
    virtual_numpad[3] = 1; #5;
    virtual_numpad[3] = 0; #3;
    virtual_numpad[4] = 1; #5;
    virtual_numpad[4] = 0; #3;
    virtual_enter = 1; #5;
    virtual_enter = 0; #3;
    virtual_logout = 1; #5;
    virtual_logout = 0; #3;
    
    //logging in after setting password
    virtual_numpad[1] = 1; #5;
    virtual_numpad[1] = 0; #3;
    virtual_numpad[2] = 1; #5;
    virtual_numpad[2] = 0; #3;
    virtual_numpad[3] = 1; #5;
    virtual_numpad[3] = 0; #3;
    virtual_numpad[4] = 1; #5;
    virtual_numpad[4] = 0; #3;
    virtual_enter = 1; #5;
    virtual_enter = 0; #3;
    virtual_logout = 1; #5;
    virtual_logout = 0; #3;
    
    //this does nothing as we are not logged in
    set_new_pass = 1; #5;
    set_new_pass = 0; #3;
    
    //logging in 
    virtual_numpad[1] = 1; #5;
    virtual_numpad[1] = 0; #3;
    virtual_numpad[2] = 1; #5;
    virtual_numpad[2] = 0; #3;
    virtual_numpad[3] = 1; #5;
    virtual_numpad[3] = 0; #3;
    virtual_numpad[4] = 1; #5;
    virtual_numpad[4] = 0; #3;
    virtual_enter = 1; #5;
    virtual_enter = 0; #3;
    
    //pressing the set new password button
    set_new_pass = 1; #5;
    set_new_pass = 0; #3;
    
    //setting new password
    virtual_numpad[5] = 1; #5;
    virtual_numpad[5] = 0; #3;
    virtual_numpad[6] = 1; #5;
    virtual_numpad[6] = 0; #3;
    virtual_numpad[7] = 1; #5;
    virtual_numpad[7] = 0; #3;
    virtual_numpad[8] = 1; #5;
    virtual_numpad[8] = 0; #3;
    virtual_enter = 1; #5;
    virtual_enter = 0; #3;
    virtual_logout = 1; #5;
    virtual_logout = 0; #3;
    
    //first incorrect attempt
    virtual_numpad[4] = 1; #5;
    virtual_numpad[4] = 0; #3;
    virtual_numpad[6] = 1; #5;
    virtual_numpad[6] = 0; #3;
    virtual_numpad[7] = 1; #5;
    virtual_numpad[7] = 0; #3;
    virtual_numpad[8] = 1; #5;
    virtual_numpad[8] = 0; #3;
    virtual_enter = 1; #5;
    virtual_enter = 0; #3;
    
    //testing out the reset button
    virtual_numpad[4] = 1; #5;
    virtual_numpad[4] = 0; #3;
    virtual_numpad[9] = 1; #5;
    virtual_numpad[9] = 0; #3;
    virtual_numpad[7] = 1; #5;
    virtual_numpad[7] = 0; #3;
    virtual_reset = 1; #5;
    virtual_reset = 0; #3;
    
    //second incorrect attempt
    virtual_numpad[2] = 1; #5;
    virtual_numpad[2] = 0; #3;
    virtual_numpad[2] = 1; #5;
    virtual_numpad[2] = 0; #3;
    virtual_numpad[7] = 1; #5;
    virtual_numpad[7] = 0; #3;
    virtual_numpad[6] = 1; #5;
    virtual_numpad[6] = 0; #3;
    virtual_enter = 1; #5;
    virtual_enter = 0; #3;
    
    //third incorrect attempt
    virtual_numpad[1] = 1; #5;
    virtual_numpad[1] = 0; #3;
    virtual_numpad[2] = 1; #5;
    virtual_numpad[2] = 0; #3;
    virtual_numpad[7] = 1; #5;
    virtual_numpad[7] = 0; #3;
    virtual_numpad[6] = 1; #5;
    virtual_numpad[6] = 0; #3;
    virtual_enter = 1; #5;
    virtual_enter = 0; #3;
    
    //locked state so does nothing
    virtual_reset = 1; #5;
    virtual_reset = 0; #3;
    
    
    $finish;
end
endmodule
