`timescale 1ns / 1ps

// GF(2^8) arithmetic with primitive polynomial x^8 + x^4 + x^3 + x^2 + 1
package gf_math_pkg;

    function automatic logic [7:0] exp_lut(input logic [7:0] i);
        case (i) 
            8'd0:exp_lut=8'h01;8'd1:exp_lut=8'h02;8'd2:exp_lut=8'h04;8'd3:exp_lut=8'h08;
            8'd4:exp_lut=8'h10;8'd5:exp_lut=8'h20;8'd6:exp_lut=8'h40;8'd7:exp_lut=8'h80;
            8'd8:exp_lut=8'h1D;8'd9:exp_lut=8'h3A;8'd10:exp_lut=8'h74;8'd11:exp_lut=8'hE8;
            8'd12:exp_lut=8'hCD;8'd13:exp_lut=8'h87;8'd14:exp_lut=8'h13;8'd15:exp_lut=8'h26;
            8'd16:exp_lut=8'h4C;8'd17:exp_lut=8'h98;8'd18:exp_lut=8'h2D;8'd19:exp_lut=8'h5A;
            8'd20:exp_lut=8'hB4;8'd21:exp_lut=8'h75;8'd22:exp_lut=8'hEA;8'd23:exp_lut=8'hC9;
            8'd24:exp_lut=8'h8F;8'd25:exp_lut=8'h03;8'd26:exp_lut=8'h06;8'd27:exp_lut=8'h0C;
            8'd28:exp_lut=8'h18;8'd29:exp_lut=8'h30;8'd30:exp_lut=8'h60;8'd31:exp_lut=8'hC0;
            8'd32:exp_lut=8'h9D;8'd33:exp_lut=8'h27;8'd34:exp_lut=8'h4E;8'd35:exp_lut=8'h9C;
            8'd36:exp_lut=8'h25;8'd37:exp_lut=8'h4A;8'd38:exp_lut=8'h94;8'd39:exp_lut=8'h35;
            8'd40:exp_lut=8'h6A;8'd41:exp_lut=8'hD4;8'd42:exp_lut=8'hB5;8'd43:exp_lut=8'h77;
            8'd44:exp_lut=8'hEE;8'd45:exp_lut=8'hC1;8'd46:exp_lut=8'h9F;8'd47:exp_lut=8'h23;
            8'd48:exp_lut=8'h46;8'd49:exp_lut=8'h8C;8'd50:exp_lut=8'h05;8'd51:exp_lut=8'h0A;
            8'd52:exp_lut=8'h14;8'd53:exp_lut=8'h28;8'd54:exp_lut=8'h50;8'd55:exp_lut=8'hA0;
            8'd56:exp_lut=8'h5D;8'd57:exp_lut=8'hBA;8'd58:exp_lut=8'h69;8'd59:exp_lut=8'hD2;
            8'd60:exp_lut=8'hB9;8'd61:exp_lut=8'h6F;8'd62:exp_lut=8'hDE;8'd63:exp_lut=8'hA1;
            8'd64:exp_lut=8'h5F;8'd65:exp_lut=8'hBE;8'd66:exp_lut=8'h61;8'd67:exp_lut=8'hC2;
            8'd68:exp_lut=8'h99;8'd69:exp_lut=8'h2F;8'd70:exp_lut=8'h5E;8'd71:exp_lut=8'hBC;
            8'd72:exp_lut=8'h65;8'd73:exp_lut=8'hCA;8'd74:exp_lut=8'h89;8'd75:exp_lut=8'h0F;
            8'd76:exp_lut=8'h1E;8'd77:exp_lut=8'h3C;8'd78:exp_lut=8'h78;8'd79:exp_lut=8'hF0;
            8'd80:exp_lut=8'hFD;8'd81:exp_lut=8'hE7;8'd82:exp_lut=8'hD3;8'd83:exp_lut=8'hBB;
            8'd84:exp_lut=8'h6B;8'd85:exp_lut=8'hD6;8'd86:exp_lut=8'hB1;8'd87:exp_lut=8'h7F;
            8'd88:exp_lut=8'hFE;8'd89:exp_lut=8'hE1;8'd90:exp_lut=8'hDF;8'd91:exp_lut=8'hA3;
            8'd92:exp_lut=8'h5B;8'd93:exp_lut=8'hB6;8'd94:exp_lut=8'h71;8'd95:exp_lut=8'hE2;
            8'd96:exp_lut=8'hD9;8'd97:exp_lut=8'hAF;8'd98:exp_lut=8'h43;8'd99:exp_lut=8'h86;
            8'd100:exp_lut=8'h11;8'd101:exp_lut=8'h22;8'd102:exp_lut=8'h44;8'd103:exp_lut=8'h88;
            8'd104:exp_lut=8'h0D;8'd105:exp_lut=8'h1A;8'd106:exp_lut=8'h34;8'd107:exp_lut=8'h68;
            8'd108:exp_lut=8'hD0;8'd109:exp_lut=8'hBD;8'd110:exp_lut=8'h67;8'd111:exp_lut=8'hCE;
            8'd112:exp_lut=8'h81;8'd113:exp_lut=8'h1F;8'd114:exp_lut=8'h3E;8'd115:exp_lut=8'h7C;
            8'd116:exp_lut=8'hF8;8'd117:exp_lut=8'hED;8'd118:exp_lut=8'hC7;8'd119:exp_lut=8'h93;
            8'd120:exp_lut=8'h3B;8'd121:exp_lut=8'h76;8'd122:exp_lut=8'hEC;8'd123:exp_lut=8'hC5;
            8'd124:exp_lut=8'h97;8'd125:exp_lut=8'h33;8'd126:exp_lut=8'h66;8'd127:exp_lut=8'hCC;
            8'd128:exp_lut=8'h85;8'd129:exp_lut=8'h17;8'd130:exp_lut=8'h2E;8'd131:exp_lut=8'h5C;
            8'd132:exp_lut=8'hB8;8'd133:exp_lut=8'h6D;8'd134:exp_lut=8'hDA;8'd135:exp_lut=8'hA9;
            8'd136:exp_lut=8'h4F;8'd137:exp_lut=8'h9E;8'd138:exp_lut=8'h21;8'd139:exp_lut=8'h42;
            8'd140:exp_lut=8'h84;8'd141:exp_lut=8'h15;8'd142:exp_lut=8'h2A;8'd143:exp_lut=8'h54;
            8'd144:exp_lut=8'hA8;8'd145:exp_lut=8'h4D;8'd146:exp_lut=8'h9A;8'd147:exp_lut=8'h29;
            8'd148:exp_lut=8'h52;8'd149:exp_lut=8'hA4;8'd150:exp_lut=8'h55;8'd151:exp_lut=8'hAA;
            8'd152:exp_lut=8'h49;8'd153:exp_lut=8'h92;8'd154:exp_lut=8'h39;8'd155:exp_lut=8'h72;
            8'd156:exp_lut=8'hE4;8'd157:exp_lut=8'hD5;8'd158:exp_lut=8'hB7;8'd159:exp_lut=8'h73;
            8'd160:exp_lut=8'hE6;8'd161:exp_lut=8'hD1;8'd162:exp_lut=8'hBF;8'd163:exp_lut=8'h63;
            8'd164:exp_lut=8'hC6;8'd165:exp_lut=8'h91;8'd166:exp_lut=8'h3F;8'd167:exp_lut=8'h7E;
            8'd168:exp_lut=8'hFC;8'd169:exp_lut=8'hE5;8'd170:exp_lut=8'hD7;8'd171:exp_lut=8'hB3;
            8'd172:exp_lut=8'h7B;8'd173:exp_lut=8'hF6;8'd174:exp_lut=8'hF1;8'd175:exp_lut=8'hFF;
            8'd176:exp_lut=8'hE3;8'd177:exp_lut=8'hDB;8'd178:exp_lut=8'hAB;8'd179:exp_lut=8'h4B;
            8'd180:exp_lut=8'h96;8'd181:exp_lut=8'h31;8'd182:exp_lut=8'h62;8'd183:exp_lut=8'hC4;
            8'd184:exp_lut=8'h95;8'd185:exp_lut=8'h37;8'd186:exp_lut=8'h6E;8'd187:exp_lut=8'hDC;
            8'd188:exp_lut=8'hA5;8'd189:exp_lut=8'h57;8'd190:exp_lut=8'hAE;8'd191:exp_lut=8'h41;
            8'd192:exp_lut=8'h82;8'd193:exp_lut=8'h19;8'd194:exp_lut=8'h32;8'd195:exp_lut=8'h64;
            8'd196:exp_lut=8'hC8;8'd197:exp_lut=8'h8D;8'd198:exp_lut=8'h07;8'd199:exp_lut=8'h0E;
            8'd200:exp_lut=8'h1C;8'd201:exp_lut=8'h38;8'd202:exp_lut=8'h70;8'd203:exp_lut=8'hE0;
            8'd204:exp_lut=8'hDD;8'd205:exp_lut=8'hA7;8'd206:exp_lut=8'h53;8'd207:exp_lut=8'hA6;
            8'd208:exp_lut=8'h51;8'd209:exp_lut=8'hA2;8'd210:exp_lut=8'h59;8'd211:exp_lut=8'hB2;
            8'd212:exp_lut=8'h79;8'd213:exp_lut=8'hF2;8'd214:exp_lut=8'hF9;8'd215:exp_lut=8'hEF;
            8'd216:exp_lut=8'hC3;8'd217:exp_lut=8'h9B;8'd218:exp_lut=8'h2B;8'd219:exp_lut=8'h56;
            8'd220:exp_lut=8'hAC;8'd221:exp_lut=8'h45;8'd222:exp_lut=8'h8A;8'd223:exp_lut=8'h09;
            8'd224:exp_lut=8'h12;8'd225:exp_lut=8'h24;8'd226:exp_lut=8'h48;8'd227:exp_lut=8'h90;
            8'd228:exp_lut=8'h3D;8'd229:exp_lut=8'h7A;8'd230:exp_lut=8'hF4;8'd231:exp_lut=8'hF5;
            8'd232:exp_lut=8'hF7;8'd233:exp_lut=8'hF3;8'd234:exp_lut=8'hFB;8'd235:exp_lut=8'hEB;
            8'd236:exp_lut=8'hCB;8'd237:exp_lut=8'h8B;8'd238:exp_lut=8'h0B;8'd239:exp_lut=8'h16;
            8'd240:exp_lut=8'h2C;8'd241:exp_lut=8'h58;8'd242:exp_lut=8'hB0;8'd243:exp_lut=8'h7D;
            8'd244:exp_lut=8'hFA;8'd245:exp_lut=8'hE9;8'd246:exp_lut=8'hCF;8'd247:exp_lut=8'h83;
            8'd248:exp_lut=8'h1B;8'd249:exp_lut=8'h36;8'd250:exp_lut=8'h6C;8'd251:exp_lut=8'hD8;
            8'd252:exp_lut=8'hAD;8'd253:exp_lut=8'h47;8'd254:exp_lut=8'h8E;
            default: exp_lut = 8'h01;
        endcase
    endfunction

    function automatic logic [7:0] log_lut(input logic [7:0] a);
        case (a)
            8'h01:log_lut=8'd0;  8'h02:log_lut=8'd1;  8'h04:log_lut=8'd2;  8'h08:log_lut=8'd3;
            8'h10:log_lut=8'd4;  8'h20:log_lut=8'd5;  8'h40:log_lut=8'd6;  8'h80:log_lut=8'd7;
            8'h1D:log_lut=8'd8;  8'h3A:log_lut=8'd9;  8'h74:log_lut=8'd10; 8'hE8:log_lut=8'd11;
            8'hCD:log_lut=8'd12; 8'h87:log_lut=8'd13; 8'h13:log_lut=8'd14; 8'h26:log_lut=8'd15;
            8'h4C:log_lut=8'd16; 8'h98:log_lut=8'd17; 8'h2D:log_lut=8'd18; 8'h5A:log_lut=8'd19;
            8'hB4:log_lut=8'd20; 8'h75:log_lut=8'd21; 8'hEA:log_lut=8'd22; 8'hC9:log_lut=8'd23;
            8'h8F:log_lut=8'd24; 8'h03:log_lut=8'd25; 8'h06:log_lut=8'd26; 8'h0C:log_lut=8'd27;
            8'h18:log_lut=8'd28; 8'h30:log_lut=8'd29; 8'h60:log_lut=8'd30; 8'hC0:log_lut=8'd31;
            8'h9D:log_lut=8'd32; 8'h27:log_lut=8'd33; 8'h4E:log_lut=8'd34; 8'h9C:log_lut=8'd35;
            8'h25:log_lut=8'd36; 8'h4A:log_lut=8'd37; 8'h94:log_lut=8'd38; 8'h35:log_lut=8'd39;
            8'h6A:log_lut=8'd40; 8'hD4:log_lut=8'd41; 8'hB5:log_lut=8'd42; 8'h77:log_lut=8'd43;
            8'hEE:log_lut=8'd44; 8'hC1:log_lut=8'd45; 8'h9F:log_lut=8'd46; 8'h23:log_lut=8'd47;
            8'h46:log_lut=8'd48; 8'h8C:log_lut=8'd49; 8'h05:log_lut=8'd50; 8'h0A:log_lut=8'd51;
            8'h14:log_lut=8'd52; 8'h28:log_lut=8'd53; 8'h50:log_lut=8'd54; 8'hA0:log_lut=8'd55;
            8'h5D:log_lut=8'd56; 8'hBA:log_lut=8'd57; 8'h69:log_lut=8'd58; 8'hD2:log_lut=8'd59;
            8'hB9:log_lut=8'd60; 8'h6F:log_lut=8'd61; 8'hDE:log_lut=8'd62; 8'hA1:log_lut=8'd63;
            8'h5F:log_lut=8'd64; 8'hBE:log_lut=8'd65; 8'h61:log_lut=8'd66; 8'hC2:log_lut=8'd67;
            8'h99:log_lut=8'd68; 8'h2F:log_lut=8'd69; 8'h5E:log_lut=8'd70; 8'hBC:log_lut=8'd71;
            8'h65:log_lut=8'd72; 8'hCA:log_lut=8'd73; 8'h89:log_lut=8'd74; 8'h0F:log_lut=8'd75;
            8'h1E:log_lut=8'd76; 8'h3C:log_lut=8'd77; 8'h78:log_lut=8'd78; 8'hF0:log_lut=8'd79;
            8'hFD:log_lut=8'd80; 8'hE7:log_lut=8'd81; 8'hD3:log_lut=8'd82; 8'hBB:log_lut=8'd83;
            8'h6B:log_lut=8'd84; 8'hD6:log_lut=8'd85; 8'hB1:log_lut=8'd86; 8'h7F:log_lut=8'd87;
            8'hFE:log_lut=8'd88; 8'hE1:log_lut=8'd89; 8'hDF:log_lut=8'd90; 8'hA3:log_lut=8'd91;
            8'h5B:log_lut=8'd92; 8'hB6:log_lut=8'd93; 8'h71:log_lut=8'd94; 8'hE2:log_lut=8'd95;
            8'hD9:log_lut=8'd96; 8'hAF:log_lut=8'd97; 8'h43:log_lut=8'd98; 8'h86:log_lut=8'd99;
            8'h11:log_lut=8'd100;8'h22:log_lut=8'd101;8'h44:log_lut=8'd102;8'h88:log_lut=8'd103;
            8'h0D:log_lut=8'd104;8'h1A:log_lut=8'd105;8'h34:log_lut=8'd106;8'h68:log_lut=8'd107;
            8'hD0:log_lut=8'd108;8'hBD:log_lut=8'd109;8'h67:log_lut=8'd110;8'hCE:log_lut=8'd111;
            8'h81:log_lut=8'd112;8'h1F:log_lut=8'd113;8'h3E:log_lut=8'd114;8'h7C:log_lut=8'd115;
            8'hF8:log_lut=8'd116;8'hED:log_lut=8'd117;8'hC7:log_lut=8'd118;8'h93:log_lut=8'd119;
            8'h3B:log_lut=8'd120;8'h76:log_lut=8'd121;8'hEC:log_lut=8'd122;8'hC5:log_lut=8'd123;
            8'h97:log_lut=8'd124;8'h33:log_lut=8'd125;8'h66:log_lut=8'd126;8'hCC:log_lut=8'd127;
            8'h85:log_lut=8'd128;8'h17:log_lut=8'd129;8'h2E:log_lut=8'd130;8'h5C:log_lut=8'd131;
            8'hB8:log_lut=8'd132;8'h6D:log_lut=8'd133;8'hDA:log_lut=8'd134;8'hA9:log_lut=8'd135;
            8'h4F:log_lut=8'd136;8'h9E:log_lut=8'd137;8'h21:log_lut=8'd138;8'h42:log_lut=8'd139;
            8'h84:log_lut=8'd140;8'h15:log_lut=8'd141;8'h2A:log_lut=8'd142;8'h54:log_lut=8'd143;
            8'hA8:log_lut=8'd144;8'h4D:log_lut=8'd145;8'h9A:log_lut=8'd146;8'h29:log_lut=8'd147;
            8'h52:log_lut=8'd148;8'hA4:log_lut=8'd149;8'h55:log_lut=8'd150;8'hAA:log_lut=8'd151;
            8'h49:log_lut=8'd152;8'h92:log_lut=8'd153;8'h39:log_lut=8'd154;8'h72:log_lut=8'd155;
            8'hE4:log_lut=8'd156;8'hD5:log_lut=8'd157;8'hB7:log_lut=8'd158;8'h73:log_lut=8'd159;
            8'hE6:log_lut=8'd160;8'hD1:log_lut=8'd161;8'hBF:log_lut=8'd162;8'h63:log_lut=8'd163;
            8'hC6:log_lut=8'd164;8'h91:log_lut=8'd165;8'h3F:log_lut=8'd166;8'h7E:log_lut=8'd167;
            8'hFC:log_lut=8'd168;8'hE5:log_lut=8'd169;8'hD7:log_lut=8'd170;8'hB3:log_lut=8'd171;
            8'h7B:log_lut=8'd172;8'hF6:log_lut=8'd173;8'hF1:log_lut=8'd174;8'hFF:log_lut=8'd175;
            8'hE3:log_lut=8'd176;8'hDB:log_lut=8'd177;8'hAB:log_lut=8'd178;8'h4B:log_lut=8'd179;
            8'h96:log_lut=8'd180;8'h31:log_lut=8'd181;8'h62:log_lut=8'd182;8'hC4:log_lut=8'd183;
            8'h95:log_lut=8'd184;8'h37:log_lut=8'd185;8'h6E:log_lut=8'd186;8'hDC:log_lut=8'd187;
            8'hA5:log_lut=8'd188;8'h57:log_lut=8'd189;8'hAE:log_lut=8'd190;8'h41:log_lut=8'd191;
            8'h82:log_lut=8'd192;8'h19:log_lut=8'd193;8'h32:log_lut=8'd194;8'h64:log_lut=8'd195;
            8'hC8:log_lut=8'd196;8'h8D:log_lut=8'd197;8'h07:log_lut=8'd198;8'h0E:log_lut=8'd199;
            8'h1C:log_lut=8'd200;8'h38:log_lut=8'd201;8'h70:log_lut=8'd202;8'hE0:log_lut=8'd203;
            8'hDD:log_lut=8'd204;8'hA7:log_lut=8'd205;8'h53:log_lut=8'd206;8'hA6:log_lut=8'd207;
            8'h51:log_lut=8'd208;8'hA2:log_lut=8'd209;8'h59:log_lut=8'd210;8'hB2:log_lut=8'd211;
            8'h79:log_lut=8'd212;8'hF2:log_lut=8'd213;8'hF9:log_lut=8'd214;8'hEF:log_lut=8'd215;
            8'hC3:log_lut=8'd216;8'h9B:log_lut=8'd217;8'h2B:log_lut=8'd218;8'h56:log_lut=8'd219;
            8'hAC:log_lut=8'd220;8'h45:log_lut=8'd221;8'h8A:log_lut=8'd222;8'h09:log_lut=8'd223;
            8'h12:log_lut=8'd224;8'h24:log_lut=8'd225;8'h48:log_lut=8'd226;8'h90:log_lut=8'd227;
            8'h3D:log_lut=8'd228;8'h7A:log_lut=8'd229;8'hF4:log_lut=8'd230;8'hF5:log_lut=8'd231;
            8'hF7:log_lut=8'd232;8'hF3:log_lut=8'd233;8'hFB:log_lut=8'd234;8'hEB:log_lut=8'd235;
            8'hCB:log_lut=8'd236;8'h8B:log_lut=8'd237;8'h0B:log_lut=8'd238;8'h16:log_lut=8'd239;
            8'h2C:log_lut=8'd240;8'h58:log_lut=8'd241;8'hB0:log_lut=8'd242;8'h7D:log_lut=8'd243;
            8'hFA:log_lut=8'd244;8'hE9:log_lut=8'd245;8'hCF:log_lut=8'd246;8'h83:log_lut=8'd247;
            8'h1B:log_lut=8'd248;8'h36:log_lut=8'd249;8'h6C:log_lut=8'd250;8'hD8:log_lut=8'd251;
            8'hAD:log_lut=8'd252;8'h47:log_lut=8'd253;8'h8E:log_lut=8'd254;
            default: log_lut = 8'd0;
        endcase
    endfunction

    function automatic logic [7:0] gf_mul(input logic [7:0] a, input logic [7:0] b);
        logic [8:0] s;
        if (a == 8'h00 || b == 8'h00) return 8'h00;
        else begin
            s = {1'b0, log_lut(a)} + {1'b0, log_lut(b)};
            if (s >= 9'd255) s = s - 9'd255;
            return exp_lut(s[7:0]);
        end
    endfunction

    function automatic logic [7:0] gf_inv(input logic [7:0] a);
        return (a == 8'h00) ? 8'h00 : exp_lut(8'd255 - log_lut(a));
    endfunction

endpackage
