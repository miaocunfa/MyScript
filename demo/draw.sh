#tbs="${tbs:-"+++++++++ ---|||"}"
tbs="+++++++++ ---|||"
 
# 主体
awk -F '\t' \
    -v table_s="$tbs" \
    'BEGIN{
    }{
        for(i=1;i<=NF;i++){
            # 每列最大长度
            cols_len[i]=cols_len[i]<length($i)?length($i):cols_len[i]
            # 每行每列值
            rows[NR][i]=$i
        }
 
        # 前后行状态
        if(NR==1){
            befor=0
        }else if(1==2){
            after=0
        }
        rows[NR][0] = befor "," NF
        befor=NF
    }END{
        # 绘制上边框
        top_line=line_val("top")
 
        # 绘制文本行
 
        # 绘制分隔行
        mid_line=line_val("mid")
        # 绘制下边框
        btm_line=line_val("btm")
 
        # 行最大总长度
        line_len_sum=0
        for(i=1;i<=length(cols_len);i++){
            line_len_sum=line_len_sum + cols_len[i] + 2
        }
        line_len_sum=line_len_sum + length(cols_len) - 1
 
        # 所有表格线预存（提高效率）
        title_top = line_val("title_top")
        top = line_val("top")
        title_mid = line_val("title_mid")
        title_btm_mid = line_val("title_btm_mid")
        title_top_mid = line_val("title_top_mid")
        mid = line_val("mid")
        title_btm = line_val("title_btm")
        btm = line_val("btm")
 
        # 绘制表格 2
        line_rows_sum=length(rows)
        for(i=1;i<=line_rows_sum;i++){
            # 状态值
            split(rows[i][0],status,",")
            befors=int(status[1])
            nows=int(status[2])
 
            if(i==1 && befors==0){
                # 首行时
                if(nows<=1){
                    # 单列
                    print title_top
                    print line_val("title_txt",rows[i][1],line_len_sum)
                
                }else if(nows>=2){
                    # 多列
                    print top
                    print line_val("txt",rows[i])
                
                }   
            }else if(befors<=1){
                # 前一行为单列时
                if(nows<=1){
                    # 单列
                    print title_mid
                    print line_val("title_txt",rows[i][1],line_len_sum)
 
                }else if(nows>=2){
                    # 多列
                    print title_btm_mid
                    print line_val("txt",rows[i])
                }
            
            }else if(befors>=2){
                # 前一行为多列时
                if(nows<=1){
                    # 单列
                    print title_top_mid
                    print line_val("title_txt",rows[i][1],line_len_sum)
 
                }else if(nows>=2){
                    # 多列
                    print mid
                    print line_val("txt",rows[i])
                }
            }
            # 表格底边
            if(i==line_rows_sum && nows<=1){
                # 尾行单列时
                print title_btm
            }else if(i==line_rows_sum && nows>=2){
                # 尾行多列时
                print btm
            }
        }
 
    }
    function line_val(   part,   txt,  cell_lens,  cell_len,  line,  i){
        # 更新本次行标
        if(part=="top"){
            tbs_l=tbs[7]
            tbs_m=tbs[8]
            tbs_r=tbs[9]
            tbs_b=tbs[11]
        }else if(part=="mid"){
            tbs_l=tbs[4]
            tbs_m=tbs[5]
            tbs_r=tbs[6]
            tbs_b=tbs[12]
 
        }else if(part=="txt"){
            tbs_l=tbs[14] tbs[10]
            tbs_m=tbs[10] tbs[15] tbs[10]
            tbs_r=tbs[10] tbs[16]
            tbs_b=tbs[10]
 
        }else if(part=="btm"){
            tbs_l=tbs[1]
            tbs_m=tbs[2]
            tbs_r=tbs[3]
            tbs_b=tbs[13]
 
        }else if(part=="title_top"){
            tbs_l=tbs[7]
            tbs_m=tbs[11]
            tbs_r=tbs[9]
            tbs_b=tbs[11]           
        }else if(part=="title_top_mid"){
            tbs_l=tbs[4]
            tbs_m=tbs[2]
            tbs_r=tbs[6]
            tbs_b=tbs[12]           
        }else if(part=="title_mid"){
            tbs_l=tbs[4]
            tbs_m=tbs[12]
            tbs_r=tbs[6]
            tbs_b=tbs[12]           
        }else if(part=="title_txt"){
            tbs_l=tbs[14]
            tbs_m=tbs[15]
            tbs_r=tbs[16]
            tbs_b=tbs[10]           
        }else if(part=="title_btm"){
            tbs_l=tbs[1]
            tbs_m=tbs[13]
            tbs_r=tbs[3]
            tbs_b=tbs[13]           
        }else if(part=="title_btm_mid"){
            tbs_l=tbs[4]
            tbs_m=tbs[8]
            tbs_r=tbs[6]
            tbs_b=tbs[12]           
        }
        # title行只有一列文本
        if(part=="title_txt"){
            cols_count=1
        }else{
            cols_count=length(cols_len)
        }
        line_tail=""
        for(i=1;i<=cols_count;i++){
            # 定义当前单元格内容，长度
            if(part=="txt"){
                cell_tail=txt[i]
                cols_len_new=cols_len[i]-length(cell_tail)
            }else if(part=="title_txt"){
                # 单列居中
                cell_tail=txt
                cols_len_new = ( cell_lens - length(cell_tail) ) / 2
                cols_len_fix = ( cell_lens - length(cell_tail) ) % 2
                #print cols_len_new,cols_len_fix
            }else{
                cell_tail = ""
                cols_len_new = cols_len[i] + 2
            }
            # 单元格文本着色
            cell_tail = clr_font cell_tail clr_end
            # 单元格内空白补全
            if(part=="title_txt"){
                # 单列
                #cols_len_new=cols_len_new/2
                for(cell_len=1;cell_len<=cols_len_new;cell_len++){
                    cell_tail= tbs_b cell_tail tbs_b
                }
                # 单列非偶长度补全
                if(cols_len_fix==1){
                    cell_tail = cell_tail " "
                }
            }else{
                # 多列
                for(cell_len=1;cell_len<=cols_len_new;cell_len++){
                    cell_tail=cell_tail tbs_b
                }
            }
            # 首格
            if(i==1){
                line_tail=line_tail cell_tail
            }else{
                # 中格
                line_tail=line_tail tbs_m cell_tail
            }
            # 尾格
            if(i==cols_count){
                line_tail=line_tail tbs_r
            }   
        }
        # 返回行
        return tbs_l line_tail
    }
    ' 
