// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_alt2gxb_aligned_rxsync.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/strxii_pcs/verilog/altera_tse_alt2gxb_aligned_rxsync.v,v $
//
// $Revision: #1 $
// $Date: 2012/10/10 $
// Check in by : $Author: swbranch $
// Author      : Siew Kong NG
//
// Project     : Triple Speed Ethernet - 1000 BASE-X PCS
//
// Description : 
//
// RX_SYNC alignment for Alt2gxb, Alt4gxb

// 
// ALTERA Confidential and Proprietary
// Copyright 2007 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

module altera_tse_gxb_aligned_rxsync (

  input clk,
  input reset,

  input [7:0] alt_dataout,
  input alt_sync,
  input alt_disperr,
  input alt_ctrldetect,
  input alt_errdetect,
  input alt_rmfifodatadeleted,
  input alt_rmfifodatainserted,
  input alt_runlengthviolation,
  input alt_patterndetect,
  input alt_runningdisp,

  output reg [7:0] altpcs_dataout,
  output altpcs_sync,
  output reg altpcs_disperr,
  output reg altpcs_ctrldetect,
  output reg altpcs_errdetect,
  output reg altpcs_rmfifodatadeleted,
  output reg altpcs_rmfifodatainserted,
  output reg altpcs_carrierdetect) ;
  parameter DEVICE_FAMILY         = "ARRIAGX";    //  The device family the the core is targetted for. 

  //-------------------------------------------------------------------------------
  // intermediate wires


  //reg altpcs_dataout

  // pipelined 1
  reg [7:0] alt_dataout_reg1;
  reg alt_sync_reg1;
  reg alt_sync_reg2;
  reg alt_disperr_reg1;
  reg alt_ctrldetect_reg1;
  reg alt_errdetect_reg1;
  reg alt_rmfifodatadeleted_reg1;
  reg alt_rmfifodatainserted_reg1;
  reg alt_patterndetect_reg1;
  reg alt_runningdisp_reg1;
  reg alt_runlengthviolation_latched;
  //-------------------------------------------------------------------------------


  always @(posedge reset or posedge clk)
    begin
        if (reset == 1'b1)
            begin
                // pipelined 1
                alt_dataout_reg1            <= 8'h0;
                alt_sync_reg1               <= 1'b0;
                alt_disperr_reg1            <= 1'b0;
                alt_ctrldetect_reg1         <= 1'b0;
                alt_errdetect_reg1          <= 1'b0;
                alt_rmfifodatadeleted_reg1  <= 1'b0;
                alt_rmfifodatainserted_reg1 <= 1'b0;
                alt_patterndetect_reg1      <= 1'b0;
                alt_runningdisp_reg1        <= 1'b0;
            end
        else
            begin
                // pipelined 1
                alt_dataout_reg1            <= alt_dataout;
                alt_sync_reg1               <= alt_sync;
                alt_disperr_reg1            <= alt_disperr;
                alt_ctrldetect_reg1         <= alt_ctrldetect;
                alt_errdetect_reg1          <= alt_errdetect;
                alt_rmfifodatadeleted_reg1  <= alt_rmfifodatadeleted;
                alt_rmfifodatainserted_reg1 <= alt_rmfifodatainserted;
                alt_patterndetect_reg1      <= alt_patterndetect;
                alt_runningdisp_reg1        <= alt_runningdisp;
            end
    
    end 
	
generate if ( DEVICE_FAMILY == "STRATIXIIGX" || DEVICE_FAMILY == "ARRIAGX" )
begin          
		always @ (posedge reset or posedge clk)
		begin
		 if (reset == 1'b1)
			begin
				altpcs_dataout              <= 8'h0;
				altpcs_disperr              <= 1'b1;
				altpcs_ctrldetect           <= 1'b0;
				altpcs_errdetect            <= 1'b1;
				altpcs_rmfifodatadeleted    <= 1'b0;
				altpcs_rmfifodatainserted   <= 1'b0;
			end
		 else
			begin
			   if (alt_sync == 1'b1 )
				 begin      
					altpcs_dataout              <= alt_dataout_reg1;
					altpcs_disperr              <= alt_disperr_reg1;
					altpcs_ctrldetect           <= alt_ctrldetect_reg1;
					altpcs_errdetect            <= alt_errdetect_reg1;
					altpcs_rmfifodatadeleted    <= alt_rmfifodatadeleted_reg1;
					altpcs_rmfifodatainserted   <= alt_rmfifodatainserted_reg1;
				 end
			   else
				 begin
					altpcs_dataout              <= 8'h0;
					altpcs_disperr              <= 1'b1;
					altpcs_ctrldetect           <= 1'b0;
					altpcs_errdetect            <= 1'b1;
					altpcs_rmfifodatadeleted    <= 1'b0;
					altpcs_rmfifodatainserted   <= 1'b0;
				 end
			end
		end
		assign altpcs_sync              = alt_sync_reg1;	      
end
else if ( DEVICE_FAMILY == "STRATIXIV" || DEVICE_FAMILY == "ARRIAIIGX" || DEVICE_FAMILY == "CYCLONEIVGX" || DEVICE_FAMILY == "HARDCOPYIV" || DEVICE_FAMILY == "ARRIAIIGZ"   || DEVICE_FAMILY == "STRATIXV" || DEVICE_FAMILY == "ARRIAV" || DEVICE_FAMILY == "ARRIAVGZ" || DEVICE_FAMILY == "CYCLONEV")
begin
	always @ (posedge reset or posedge clk)
    begin
     if (reset == 1'b1)
        begin
            altpcs_dataout              <= 8'h0;
            altpcs_disperr              <= 1'b1;
            altpcs_ctrldetect           <= 1'b0;
            altpcs_errdetect            <= 1'b1;
            altpcs_rmfifodatadeleted    <= 1'b0;
            altpcs_rmfifodatainserted   <= 1'b0;
			alt_sync_reg2               <= 1'b0;
        end
     else
        begin     
                altpcs_dataout              <= alt_dataout_reg1;
                altpcs_disperr              <= alt_disperr_reg1;
                altpcs_ctrldetect           <= alt_ctrldetect_reg1;
                altpcs_errdetect            <= alt_errdetect_reg1;
                altpcs_rmfifodatadeleted    <= alt_rmfifodatadeleted_reg1;
                altpcs_rmfifodatainserted   <= alt_rmfifodatainserted_reg1;
				alt_sync_reg2               <= alt_sync_reg1 ;
        end

    end
	

    assign altpcs_sync              = alt_sync_reg2;
end      
endgenerate




      
   //latched runlength violation assertion for "carrier_detect" signal generation block
   //reset the latch value after carrier_detect goes de-asserted
//   always @ (altpcs_carrierdetect or alt_runlengthviolation or alt_sync_reg1)
//    begin
//       if (altpcs_carrierdetect == 1'b0)
//        begin
//           alt_runlengthviolation_latched <= 1'b0;
//        end 
//       else
//        begin 
//           if (alt_runlengthviolation == 1'b1 & alt_sync_reg1 == 1'b1)
//            begin
//               alt_runlengthviolation_latched <= 1'b1;
//            end
//        end       
//    end
  

//    always @ (posedge reset or posedge clk)
//     begin
//      if (reset == 1'b1)
//         begin
//             alt_runlengthviolation_latched_reg <= 1'b0;
//         end
//      else
//         begin
//             alt_runlengthviolation_latched_reg <= alt_runlengthviolation_latched;
//         end
//     end

    always @ (posedge reset or posedge clk)
     begin
      if (reset == 1'b1)
         begin
             alt_runlengthviolation_latched <= 1'b0;
         end
      else
       begin
           if ((altpcs_carrierdetect == 1'b0) | (alt_sync == 1'b0))
            begin
               alt_runlengthviolation_latched <= 1'b0;
            end 
           else
            begin 
               if ((alt_runlengthviolation == 1'b1) & (alt_sync == 1'b1))
                begin
                   alt_runlengthviolation_latched <= 1'b1;
                end
            end       
       end
     end


   // carrier_detect signal generation
   always @ (posedge reset or posedge clk)
    begin
     if (reset == 1'b1)
        begin
            altpcs_carrierdetect <= 1'b1;
        end
     else

        // This portion of code is to workaround the issue with PHYIP (hard PCS) for not implementing the carrier_detect, 
        // which suppose to be implemented based on 10b character, not 8b. 
        // 
        // The real challenge is to detect the /INVALID/ 10b code group
        //
        // This is the Table 36.3.2.1 in UNH test plan
        // =====================================================
        // RD-          code-group     RD+            code-group
        // =====================================================
        // 001111 1010  /K28.5/        110000 0101    /K28.5/
        // 001111 1011  /INVALID/      110000 0100    /INVALID/
        // 001111 1000  /K28.7/        110000 0111    /K28.7/
        // 001111 1110  /INVALID/      110000 0001    /INVALID/
        // 001111 0010  /K28.4/        110000 1101    /K28.4/
        // 001110 1010  /D28.5/        110001 0101    /D3.2/
        // 001101 1010  /D12.5/        110010 0101    /D19.2/
        // 001011 1010  /D20.5/        110100 0101    /D11.2/
        // 000111 1010  /D7.5/         111000 0101    /D7.2/
        // 011111 1010  /INVALID/      100000 0101    /INVALID/
        // 101111 1010  /INVALID/      010000 0101    /INVALID/

        begin
           if (  (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h1C & alt_ctrldetect_reg1 == 1'b1 & alt_errdetect_reg1 == 1'b1  
                    & alt_disperr_reg1 ==1'b1 & alt_patterndetect_reg1 == 1'b1 & alt_runlengthviolation_latched == 1'b0                 ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h1C & alt_ctrldetect_reg1 == 1'b1 & alt_errdetect_reg1 == 1'b1  
                    & alt_disperr_reg1 ==1'b1 & alt_patterndetect_reg1 == 1'b0 & alt_runlengthviolation_latched == 1'b0                 ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hFC & alt_ctrldetect_reg1 == 1'b1 & alt_patterndetect_reg1 == 1'b1      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hFC & alt_ctrldetect_reg1 == 1'b1 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h9C & alt_ctrldetect_reg1 == 1'b1 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hBC & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hAC & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hB4 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hA7 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0 
                    & alt_runningdisp_reg1 == 1'b1                                                                                      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hA1 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0 
                    & alt_runningdisp_reg1 == 1'b1 & alt_runlengthviolation_latched == 1'b1                                             ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hA2 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0 
                   & alt_runningdisp_reg1 == 1'b1  
                   & ((alt_runningdisp == 1'b1 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b1)|
                      (alt_runningdisp == 1'b0 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b0)|
                      (alt_runningdisp == 1'b1 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b0))                                ) |

                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h43 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h53 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h4B & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h47 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0
                   & alt_runningdisp_reg1 == 1'b0                                                                                       ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h41 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0
                   & alt_runningdisp_reg1 == 1'b0 & alt_runlengthviolation_latched == 1'b1 
                   & ((alt_runningdisp == 1'b1 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b0)|                                                                                
                      (alt_runningdisp == 1'b0 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b1 ))                               ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h42 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0
                   & alt_runningdisp_reg1 == 1'b0 & ((alt_runningdisp == 1'b1 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b0)|
                                                     (alt_runningdisp == 1'b0 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b1)) )  
              )

             begin      
                altpcs_carrierdetect              <= 1'b0;
             end
           else
             begin
                altpcs_carrierdetect              <= 1'b1;
             end
        end

    end




endmodule
