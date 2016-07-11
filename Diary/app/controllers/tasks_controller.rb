class TasksController < ApplicationController
  # GET /tasks
  # GET /tasks.xml
  def index

    #breakpoint
    #print "HERE"
    @tasks = Task.find(:all, :conditions => [ "category_id=?", 3 ] )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # # GET /tasks/new
  # # GET /tasks/new.xml
  # def new
  #   @post = Post.new

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @post }
  #   end
  # end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
  end

  # # POST /tasks
  # # POST /tasks.xml
  # def create
  #   @post = Post.new(params[:post])
  #   respond_to do |format|
  #     if @post.save
  #       format.html { redirect_to(@post, :notice => 'Post was successfully created.') }
  #       format.xml  { render :xml => @post, :status => :created, :location => @post }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:post])
        format.html { redirect_to(@task, :notice => 'Post was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # # DELETE /tasks/1
  # # DELETE /tasks/1.xml
  # def destroy
  #   @post = Post.find(params[:id])
  #   @post.destroy
  #   respond_to do |format|
  #     format.html { redirect_to(tasks_url) }
  #     format.xml  { head :ok }
  #   end
  # end
end
