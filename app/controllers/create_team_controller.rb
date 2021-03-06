class CreateTeamController < ApplicationController
  include Wicked::Wizard
  require "open-uri"
  steps :new, :questionnaire, :confirm

  def show
    session[:create_team] = session[:create_team] || {}
    questions = policy_scope(Question)

    case step
    when :new
      if session[:create_team] && session[:create_team]["team"]
        @team = Team.new(session[:create_team]["team"])
       else
         @team = Team.new
       end
    when :questionnaire
      @questions = questions.where('custom = true')
      @categories = @questions.map(&:category).uniq
      @selected = session[:create_team]["questions"] || []
    end
    render_wizard
  end

  def update
    session[:create_team] = session[:create_team] || {}
    case step
    when :new
      if params[:team][:photo]
        @team_picture = Cloudinary::Uploader.upload(params[:team][:photo])["url"]
        session[:create_team][:photo] = @team_picture
      end
      session[:create_team][:team] = team_params
    redirect_to wizard_path(@next_step)
    when :questionnaire
      session[:create_team]["questions"] = params[:question_ids]
    redirect_to wizard_path(@next_step)
    end
  end

  def create
    # Create a new team
    team = Team.new(session[:create_team]["team"])
    if session[:create_team]["photo"]
      photo = open(session[:create_team]["photo"])
      team.photo.attach(io: photo, filename: "team photo")
    end
    team.save

    # Add team membership for owner
    membership_owner = Membership.new(user: current_user, team: team, owner: true, status: 0)
    membership_owner.save

    # Add team memberships for team members (invitees)
    session[:create_team]["team"]["email"].split(",").each do |email| # might add semicolons, dashes etc.
      team.invite(email.strip) unless email.strip == current_user.email
    end

    # Set up team_questions
    session[:create_team]["questions"].each do |question_id|
      question = Question.find(question_id)
      team_question = TeamQuestion.new(question: question, team: team)
      team_question.save
    end

    session.delete(:create_team)
    redirect_to team_questions_path(team)
  end

  private

  def team_params
    params.require(:team).permit(:name, :description, :email)
  end
end
