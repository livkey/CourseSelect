class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update]
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end
  
  def open
    @course = Course.find_by_id(params[:id])
    @course.update_attributes(:open=>true)
    redirect_to courses_path, flash: {:success => "已经成功开放该课程:#{ @course.name}"}
  end

  def close
    @course = Course.find_by_id(params[:id])
    @course.update_attributes(:open=>false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end
  #学生名单导出
  def stuexport
    @course = Course.find_by_id(params[:id])
        require 'tempfile'
        temp_file = Tempfile.new("#{current_user.id.to_s+'_'+@course.name}.xls")
        workbook = Spreadsheet::Workbook.new
        worksheet = workbook.create_worksheet
        worksheet.row(0).concat %w{学号 姓名 邮箱 专业 培养单位}
        @course.users.each_with_index do |user , i|
          worksheet.row(i+1).push user.num, user.name, user.email, user.major, user.department
        end 
        workbook.write temp_file
        send_file temp_file, :type => "application/vnd.ms-excel", :filename => "#{@course.name}.xls", :stream => false
        # temp_file.rewind
  end
  
  def courseplan
      @course=Course.find_by_id(params[:id])
  end
  
  def courseaim
    @course=Course.find_by_id(params[:id])
  end
  
  def courseteacher
    @course=Course.find_by_id(params[:id])
  end
  
  def coursecontent
    @course=Course.find_by_id(params[:id])
  end
  #显示学生列表
  def studentlist
    @course = Course.find_by_id(params[:id])
    @user = @course.users
  end
  #-------------------------for students----------------------



  def list
     #   按照关键词（课程名称、教师名）或者下拉列表进行查询
    @course = Array.new
    @queryType = params[:queryType].to_i
    if @queryType.nil? == false
     @queryinfo = params[:query]
     if @queryinfo.nil? == false
      # 课程名称
        if @queryType == 2 
            @course = Course.where("name like '%#{@queryinfo}%'")  
            # 授课教师姓名
        elsif @queryType == 10
            @teacherName = User.where("name like '%#{@queryinfo}%'")
            @teacherName.each do |teacherSingle|
                teacherSingle.teaching_courses.each do |courseSingle|
                    @course.push courseSingle
                end
            end
            # 课程编号
        elsif @queryType == 1
            @course = Course.where("course_code like '#{@queryinfo}%'")
            # 课时学分
        elsif @queryType == 3
            @course = Course.where("credit like '#{@queryinfo}'")
            # 课程类型
        elsif @queryType == 4
            @course = Course.where("course_type like '#{@queryinfo}'")
            # 授课方式
        elsif @queryType == 5
            @course = Course.where("teaching_type like '#{@queryinfo}'")
            # 考试方式
        elsif @queryType == 6
            @course = Course.where("exam_type like '#{@queryinfo}'")
            # 授课地点
        elsif @queryType == 7
            @course = Course.where("class_room like '#{@queryinfo}%'")
            # 上课周数
        elsif @queryType == 8
            @course = Course.where("course_week like '#{@queryinfo}'")
            # 上课时间
        elsif @queryType == 9
            @course = Course.where("course_time like '#{@queryinfo}'")    
        else
            @course = Course.all
        end
     else
         @course=Course.all 
     end
    else
        @course = Course.all
    end
   
    
    @course=@course-current_user.courses
    @course_true = Array.new
    @course.each do |single|
      if single.open then
        @course_true.push single
      end
    end
  end
  
  def tranform_course_time(course,single)#课时间类型转换函数  #最好改成直输入一个变量的函数，因为两个参数类型一样
                                         #操作也一样，再写一个去变量值的方法。不要用全局变量
    left_bracket=course.index("(")
    right_bracket=course.index(")")
    mid_line=course.index("-")
       
    left_bracket1=single.index("(")
    right_bracket1=single.index(")")
    mid_line1=single.index("-")
    
    $day_of_week=course[0..left_bracket-1]
    first_class=course[left_bracket+1..mid_line-1]
    $first_class=first_class.to_i(base=10) #转化成数字，生成课程的时候要用
    last_class=course[mid_line+1..right_bracket-1]
    $last_class=last_class.to_i(base=10) #转化成数字，生成课程的时候要用
      
    $day_of_week1=single[0..left_bracket1-1]
    first_class1=single[left_bracket1+1..mid_line1-1]
    $first_class1=first_class1.to_i(base=10) #转化成数字，生成课程的时候要用
    last_class1=single[mid_line1+1..right_bracket1-1]
    $last_class1=last_class1.to_i(base=10) #转化成数字，生成课程的时候要用
    
  end

  def test_course_conflict(course)
    current_user.courses.each do |single|
      tranform_course_time(course.course_time.strip,single.course_time.strip)
      #if single.course_time == course.course_time #冲突  最好写成一个方法判断是否冲突
      if $day_of_week==$day_of_week1
        if $last_class>= $first_class1 or $first_class<=$last_class1
          return current_user.course_not_conflict = false
        else
          current_user.course_not_conflict = true
        end
      else  
        current_user.course_not_conflict = true
        break
      end
    end
  end
  
  # 选为旁听课(不论人数限制、不论是否冲突)
  def selectasPT
   @course=Course.find_by_id(params[:id])
    current_user.courses<<@course
    @grades=current_user.grades.find_by(course_id: params[:id])
     @grades.update_attributes(:degree => 3)
     flash={:success => "成功选择该课程为旁听课: #{@course.name}"}
     redirect_to list_courses_path, flash: flash
  end
  
  #选为学位课
  def selectasdegree
   @course=Course.find_by_id(params[:id])  #当前选的课程，检查无冲突再加入
    test_course_conflict(@course)
    if current_user.course_not_conflict #无冲突
      if @course.student_num.nil? or @course.student_num<=0
        @course.student_num=0
      end
      #选课人数限制:达到限制人数不能加入课程
      if @course.limit_num.nil? == false and @course.limit_num>0
        if @course.limit_num < @course.student_num+1
          flash={:danger => "课容量已满: #{@course.course_code}, #{@course.name}, #{@course.teacher.name }, #{@course.limit_num}"}
           redirect_to list_courses_path, flash: flash
        end
      end
      if @course.limit_num.nil? or @course.limit_num<=0
        @course.limit_num=0
      end
      
      #成功选课
      @course.student_num +=1
      @course.update_attributes(:student_num => @course.student_num)
      current_user.courses<<@course  
      @grades=current_user.grades.find_by(course_id: params[:id])
      @grades.update_attributes(:degree => 1)
      flash={:success => "成功选择课程为学位课: #{@course.course_code}, #{@course.name}, #{@course.teacher.name }, #{@course.course_time}"}
      redirect_to list_courses_path, flash: flash   #选完课后应停留在选课页面，否则继续选课很麻烦
           
    else 
      flash={:danger => "选课冲突！冲突课程: #{@course.course_code}, #{@course.name}, #{@course.teacher.name }, #{@course.course_time}"}
      redirect_to list_courses_path, flash: flash
    end
  end

#选为非学位课
  def selectasnondegree                     #选课为什么不修改选课人数    #已修改 2017.1.1
    @course=Course.find_by_id(params[:id])  #当前选的课程，检查无冲突再加入
    test_course_conflict(@course)
    if current_user.course_not_conflict #无冲突
      if @course.student_num.nil? or @course.student_num<=0
        @course.student_num=0
      end
      #选课人数限制
      if @course.limit_num.nil? == false and @course.limit_num>0
        if @course.limit_num < @course.student_num+1
          flash={:danger => "课容量已满: #{@course.course_code}, #{@course.name}, #{@course.teacher.name }, #{@course.limit_num}"}
           redirect_to list_courses_path, flash: flash
        end
      end
     
      if @course.limit_num.nil? or @course.limit_num<=0
        @course.limit_num=0
      end
      
      #成功选课
      @course.student_num +=1
      @course.update_attributes(:student_num => @course.student_num)  
      current_user.courses<<@course  
      @grades=current_user.grades.find_by(course_id: params[:id])
      @grades.update_attributes(:degree => 0)
      flash={:success => "成功选择课程为非学位课: #{@course.course_code}, #{@course.name}, #{@course.teacher.name }, #{@course.course_time}"}
      redirect_to list_courses_path, flash: flash   #选完课后应停留在选课页面，否则继续选课很麻烦
      
    else 
      flash={:danger => "选课冲突！冲突课程: #{@course.course_code}, #{@course.name}, #{@course.teacher.name }, #{@course.course_time}"}
      redirect_to list_courses_path, flash: flash
    end
    
  end

  def quit
    @course=Course.find_by_id(params[:id])
    @grades=current_user.grades.find_by(course_id: params[:id])
    if @course.student_num.nil? or @course.student_num<=0
        @course.student_num=0
    end
    @course.update_attributes(:open=>true)
    if @grades.degree != 3
      @course.student_num -=1
      if @course.student_num.nil? or @course.student_num<=0
          @course.student_num=0
      end
      @course.update_attributes(:student_num => @course.student_num)
    end
    
    current_user.courses.delete(@course)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
    
  end
  
  def credittips
    @courses=current_user.courses
    @grades=current_user.grades
    
    #选课学分统计
    @chosen_PT_all = 0.0
    @chosen_credit_all = 0.0
    @chosen_credit_public = 0.0
    @chosen_credit_major = 0.0
    
    @grades.each do |grade|
      #旁听课
      if grade.degree == 3
          @chosen_PT_all = @chosen_PT_all + grade.course.credit[-3..-1].to_f
      else
        @chosen_credit_all += grade.course.credit[-3..-1].to_f
        #公选课
        if grade.course.course_type == "公共选修课"
          @chosen_credit_public += grade.course.credit[-3..-1].to_f
        end
        #学位课
        if grade.degree == 1
          @chosen_credit_major += grade.course.credit[-3..-1].to_f
        end
      end
    end
    
    #已获得学分统计 
    @obtained_PT_all = 0.0
    @obtained_credit_pubic = 0.0
    @obtained_credit_major = 0.0
    @obtained_credit_all = 0.0
    
    @grades.each do |grade|
      if grade.grade.nil? == false
        #旁听课
        if grade.degree == 3 
          @obtained_PT_all = @obtained_PT_all + grade.course.credit[-3..-1].to_f
        else
          @obtained_credit_all += grade.course.credit[-3..-1].to_f
          if grade.course.course_type == "公共选修课"
            @obtained_credit_public += grade.course.credit[-3..-1].to_f
          end
          if grade.degree == 1
             @obtained_credit_major += grade.course.credit[-3..-1].to_f
          end
        end
      end
    end
  end

  def filter
    redirect_to list_courses_path(params)
    
  end
 
  def modifydegree
    @grades=current_user.grades.find_by(course_id: params[:id])
    @courseName = Course.find_by_id(params[:id]).name
    if @grades.degree == 1 then
      @grades.update_attributes(:degree => 0)
      flash={:success => "#{@courseName}更改为非学位课"}
    #旁听课不可以修改
    #elsif @grades.degree == 3 then       
    #  @grades.update_attributes(:degree => 0)
    #  flash={:success => "#{@courseName}更改为非学位课"}
    elsif @grades.degree == 0 then  
      @grades.update_attributes(:degree => 1)
      flash={:success => "#{@courseName}更改为学位课"}
    end
    redirect_to courses_path, flash: flash
  end

  def course_schedule
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?
  end

 
  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?
    
    @course_all=Course.all
    @course_all=@course_all-@course
    @course_true = Array.new
    @course_all.each do |single|
      if single.open then
        @course_true.push single
      end
    end
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登录'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登录'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登录'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week, :open,
                                   :course_content, :course_aim, :course_teacher)
  end


end