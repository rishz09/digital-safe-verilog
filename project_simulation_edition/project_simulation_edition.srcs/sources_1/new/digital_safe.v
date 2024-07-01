`timescale 1ns / 1ps

module virtual_button(pulseclk, button, pulse);

input pulseclk;
input button;
reg prev_button_state, button_state;

output reg pulse;

//to prevent all 4 digits from filling up at once
always @(posedge pulseclk) 
begin
    prev_button_state <= button_state;
    button_state <= button;
    
    if (button_state && !prev_button_state) 
    begin
        pulse <= 1;
    end 
    else 
    begin
        pulse <= 0;
    end
end
endmodule

module BCD({A,B,C,D},bcd);
    input A,B,C,D;
    output [6:0]bcd;
    wire A1,B1,C1,D1;
    not(A1,A);
    not(B1,B);
    not(C1,C);
    not(D1,D);
    assign bcd[0]=~(C|A|(B1&D1)|(B&D));
    assign bcd[1]=~(A|B1|(C&D)|(C1&D1));
    assign bcd[2]=~(A|B|C1|D);
    assign bcd[3]=~((B1&D1)|(C&D1)|(B1&C)|(B&C1&D));
    assign bcd[4]=~((C&D1)|(B1&D1));
    assign bcd[5]=~(A|(B&C1)|(C1&D1)|(B&D1));
    assign bcd[6]=~(A|(B&C1)|(C&D1)|(B1&C));
endmodule


module digital_safe( virtual_numpad, virtual_enter , set_new_pass , virtual_reset , virtual_logout, sysclk, custom_clk , loggedin_led, ssd, loggedout_led , present_state , seto , locked_led, locked_led1, locked_led2, locked_led3, locked_led4, enable, custom_state_display );
    
    //comment for prototype
    input custom_clk;
    //storing number to be inputted by the user
    input [9:0]virtual_numpad;
    
    input virtual_enter , set_new_pass , virtual_reset , virtual_logout;
    wire virtual_set;
//    ?
    assign virtual_set=~set_new_pass;
    wire [9:0]numpad;
    wire back , enter , set , reset , lgout;
    output seto;
    assign seto = set;
    //comment for simulation
    input sysclk;
    
    output reg loggedin_led = 1'b0;
    output reg loggedout_led = 1'b1;
    output reg locked_led = 1'b0;
    output reg locked_led1 = 1'b0;
    output reg locked_led2 = 1'b0;
    output reg locked_led3 = 1'b0;
    output reg locked_led4 = 1'b0;

    output reg[6:0] custom_state_display= 7'b0000110;

    output reg [3:0]enable=4'b1111;
    
    reg [3:0]pass1=4'b0000;
    reg [3:0]pass2=4'b0000;
    reg [3:0]pass3=4'b0000;
    reg [3:0]pass4=4'b0000;

    reg [3:0]entered_pass1=4'b0000;
    reg [3:0]entered_pass2=4'b0000;
    reg [3:0]entered_pass3=4'b0000;
    reg [3:0]entered_pass4=4'b0000;
    //comment for simulation
//    output reg custom_clk = 1'b0;
    
    //parameters are the binary numbers chosen for different states
    parameter[3:0] init_state = 4'b0000 , logout = 4'b0110 , login = 4'b0101 , locked = 4'b1011;
    parameter[3:0] num1 = 4'b0001 , num2 = 4'b0010 , num3 = 4'b0011 , num4 = 4'b0100; 
    parameter[3:0] entered_num1 = 4'b0111 , entered_num2 = 4'b1000 , entered_num3 = 4'b1001 , entered_num4 = 4'b1010; 
//    reg[5:0] count = 0;
    reg [1:0]incorrect_attempts = 2'b00;
//    reg [31:0]locked_counter = 0; 
    
    output reg [6:0]ssd = 7'b0000000;
    //7 segment display array for set password
    wire [6:0]ssd1;
    wire [6:0]ssd2;
    wire [6:0]ssd3;
    wire [6:0]ssd4;
    
    //for entered password
    wire [6:0]entered_ssd1;
    wire [6:0]entered_ssd2;
    wire [6:0]entered_ssd3;
    wire [6:0]entered_ssd4;
    
    //getting the 7 segment display array for each digit
    BCD sd1(pass1,ssd1);
    BCD sd2(pass2,ssd2);
    BCD sd3(pass3,ssd3);
    BCD sd4(pass4,ssd4);
    
    //for password is which is being currently entered
    BCD entered_sd1(entered_pass1,entered_ssd1);
    BCD entered_sd2(entered_pass2,entered_ssd2);
    BCD entered_sd3(entered_pass3,entered_ssd3);
    BCD entered_sd4(entered_pass4,entered_ssd4); 
    
    virtual_button v1(sysclk,virtual_numpad[0],numpad[0]);
    virtual_button v2(sysclk,virtual_numpad[1],numpad[1]);
    virtual_button v3(sysclk,virtual_numpad[2],numpad[2]);
    virtual_button v4(sysclk,virtual_numpad[3],numpad[3]);
    virtual_button v5(sysclk,virtual_numpad[4],numpad[4]);
    virtual_button v6(sysclk,virtual_numpad[5],numpad[5]);
    virtual_button v7(sysclk,virtual_numpad[6],numpad[6]);
    virtual_button v8(sysclk,virtual_numpad[7],numpad[7]);
    virtual_button v9(sysclk,virtual_numpad[8],numpad[8]);
    virtual_button v10(sysclk,virtual_numpad[9],numpad[9]);
    
    virtual_button v11(sysclk,virtual_enter,enter);
    virtual_button v12(sysclk,virtual_logout,lgout);
    virtual_button v13(sysclk,virtual_set,set);
    virtual_button v14(sysclk,virtual_reset,reset);
    
    //present state of the safe in binary, on LEDs
    output reg [3:0]present_state = init_state;
    
//    this is for assigning values to ssd at each ig, using custom states ig?
    always @(posedge custom_clk )
    begin
        case(present_state)

            init_state, num1, num2, num3, num4:
            begin
                case(enable)
                4'b1111:
                begin
                    enable<=4'b0111;
                    ssd<=ssd1;
                end
                4'b0111:
                begin
                    
                    enable<=4'b1011;
                    ssd<=ssd2;
                end
                4'b1011:
                begin
                    
                    enable<=4'b1101;
                    ssd<=ssd3;
                end
                4'b1101:
                begin
                    
                    enable<=4'b1110;
                    ssd<=ssd4;
                end
                4'b1110:
                begin
                    
                    enable<=4'b0111;
                    ssd <= ssd1;
                end
                endcase
            end
            
            entered_num1, entered_num2, entered_num3, entered_num4:
            begin
                case(enable)
                4'b1111:
                begin
                    enable<=4'b0111;
                    ssd<=entered_ssd1;
                end
                4'b0111:
                begin
                    
                    enable<=4'b1011;
                    ssd<=entered_ssd2;
                end
                4'b1011:
                begin
                    
                    enable<=4'b1101;
                    ssd<=entered_ssd3;
                end
                4'b1101:
                begin
                    
                    enable<=4'b1110;
                    ssd<=entered_ssd4;
                end
                4'b1110:
                begin
                    
                    enable<=4'b0111;
                    ssd <= entered_ssd1;
                end
                endcase
            end
            login, logout, locked:
            begin
                enable<=4'b1111;
            end
            
        endcase
    end
    
    integer i=0;
    always @( posedge sysclk )
    begin
        
        case(present_state)
        
        //for initial state
        init_state:
        begin

        //Number entries    
        loggedin_led <= 1'b0;
        loggedout_led <= 1'b1;
        
        //for each if statement, moving to next state, and setting the first digit of password
        for(i=0; i<=9; i=i+1) begin
            if(numpad[i] == 1) begin
                present_state <= num1;
                pass1 <= i;
            end
        end
        end
        
        //case when one digit has been entered
        num1:
        begin
        
         //for each if statement, moving to next state, and setting the second digit of password   
         for(i=0; i<=9; i=i+1) begin
            if(numpad[i] == 1) begin
                present_state <= num2;
                pass2 <= i;
            end
         end
        
        //applying the reset case which resets state and every digit
            if( reset == 1 )
            begin
            present_state <= init_state;
            pass1 <= 4'b0000;
            pass2 <= 4'b0000;
            pass3 <= 4'b0000;
            pass4 <= 4'b0000;
            end
        
        end
        
        //case when 2 digits have been entered
        num2:
        begin
        
        //for each if statement, moving to next state, and setting the third digit of password   
        for(i=0; i<=9; i=i+1) begin
            if(numpad[i] == 1) begin
                present_state <= num3;
                pass3 <= i;
            end
         end
         
        //reset case
            if( reset == 1 )
            begin
            present_state <= init_state;
            pass1 <= 4'b0000;
            pass2 <= 4'b0000;
            pass3 <= 4'b0000;
            pass4 <= 4'b0000;
            end

        end
        
        //case when 3 digits have been entered
        num3:
        begin

        //for each if statement, moving to next state, and setting the fourth digit of password  
        for(i=0; i<=9; i=i+1) begin
            if(numpad[i] == 1) begin
                present_state <= num4;
                pass4 <= i;
            end
         end
        //reset case
            if( reset == 1 )
            begin
            pass1 <= 4'b0000;
            pass2 <= 4'b0000;
            pass3 <= 4'b0000;
            pass4 <= 4'b0000;
            end

        end
        
        //case when four digits have been entered
        num4:
        begin

        //go to login state
        if( enter == 1 )
            begin
            present_state <= login;
            end

        else if( reset == 1 )
            begin
            present_state <= init_state;
            pass1 <= 4'b0000;
            pass2 <= 4'b0000;
            pass3 <= 4'b0000;
            pass4 <= 4'b0000;
            end

        end


        //logged out case (0001)
        logout:
        begin
        
        entered_pass1<=4'b0000;
        entered_pass2<=4'b0000;
        entered_pass3<=4'b0000;
        entered_pass4<=4'b0000;
        
        loggedin_led <= 1'b0;
        loggedout_led <= 1'b1;
        
        //changing state to that of locked state if no of incorrect attempts > 3
        if(incorrect_attempts == 2'b11)
            begin
            present_state<=locked;
            end

        //Moving to the state of having inputted the first digit to login    
        for(i=0; i<=9; i=i+1) begin
            if(numpad[i] == 1) begin
                present_state <= entered_num1;
                entered_pass1 <= i;
            end
         end
        
        if(incorrect_attempts == 2'b00) begin
            custom_state_display <= 7'b1000000;
        end
            
        else if(incorrect_attempts == 2'b01) begin
                custom_state_display <= 7'b1011011;
             end
        
        else if(incorrect_attempts == 2'b10) begin
                custom_state_display <= 7'b0110000;
        end
        end

        entered_num1:
        begin

        //Moving to the state of having inputted the second digit to login   
        for(i=0; i<=9; i=i+1) begin
            if(numpad[i] == 1) begin
                present_state <= entered_num2;
                entered_pass2 <= i;
            end
         end
        
        //resetting inputted password values for logging in
            if( reset == 1 )
            begin
            present_state <= logout;
            entered_pass1 <= 4'b0000;
            entered_pass2 <= 4'b0000;
            entered_pass3 <= 4'b0000;
            entered_pass4 <= 4'b0000;
            end
        
        end
        
        //Moving to the state of having inputted the third digit to login
        entered_num2:
        begin

        //Num2 Number entries    
         for(i=0; i<=9; i=i+1) begin
            if(numpad[i] == 1) begin
                present_state <= entered_num3;
                entered_pass3 <= i;
            end
         end

            if( reset == 1 )
            begin
            present_state<=logout;
            entered_pass1 <= 4'b0000;
            entered_pass2 <= 4'b0000;
            entered_pass3 <= 4'b0000;
            entered_pass4 <= 4'b0000;
            end

        end
        
        //Moving to the state of having inputted the fourth digit to login
        entered_num3:
        begin

        //Num3 Number entries    
         for(i=0; i<=9; i=i+1) begin
            if(numpad[i] == 1) begin
                present_state <= entered_num4;
                entered_pass4 <= i;
            end
         end

            if( reset == 1 )
            begin
            present_state<=logout;
            entered_pass1 <= 4'b0000;
            entered_pass2 <= 4'b0000;
            entered_pass3 <= 4'b0000;
            entered_pass4 <= 4'b0000;
            end

        end
        
        entered_num4:
        begin

         if( enter == 1 )
            begin
            //logging in and changing state to logged in only if all digits match. also resetting number of wrong attempts
            if( pass1==entered_pass1 && pass2==entered_pass2 && pass3==entered_pass3 && pass4==entered_pass4  )
                begin
                present_state<=login;
                entered_pass1 <= 4'b0000;
                entered_pass2 <= 4'b0000;
                entered_pass3 <= 4'b0000;
                entered_pass4 <= 4'b0000;
                incorrect_attempts<=2'b00;
                end
            else
            //moving back to logout state, and incrementing number of incorrect inputs by 1
                begin
                present_state<=logout;
                incorrect_attempts <= incorrect_attempts+1;
                end

            end

        else if( reset == 1 )
            begin
            present_state<=logout;
            entered_pass1 <= 4'b0000;
            entered_pass2 <= 4'b0000;
            entered_pass3 <= 4'b0000;
            entered_pass4 <= 4'b0000;
            end

        end
        
        login:
        begin

        loggedout_led <= 1'b0;
        loggedin_led <= 1'b1;
        
        //move to logged out state
        if( lgout == 1 )
            begin
            present_state <= logout;
            loggedin_led <= 1'b0;
            end
        
        //to set password once again
        else if( set == 1 )
            begin
            present_state <= init_state;
            end
        if(set == 1)
        custom_state_display <= 7'b0000110;
        else
        custom_state_display <= 7'b1101101;
        end
        
        //glow all LEDs and set necessary variables
        locked:
        begin
        locked_led <= 1'b1;
        locked_led1 <= 1'b1;
        locked_led2 <= 1'b1;
        locked_led3 <= 1'b1;
        locked_led4 <= 1'b1;
        loggedout_led <= 1'b0;
        incorrect_attempts <= 2'b00;
        custom_state_display <= 7'b1110001;
        end
        
        endcase
    end
endmodule
