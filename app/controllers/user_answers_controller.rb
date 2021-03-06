class UserAnswersController < ApplicationController
  def create
    @team = Team.find(params[:id])
    authorize @team
    @questions = policy_scope(@team.questions)
    user = current_user

    if params[:user_answers].values.count("") == 0
      # find existing answers and destroy existing records
      existing_user_answers = UserAnswer.where("team_id = ? AND user_id = ?", @team.id, user.id)

      existing_user_answers.each do |user_answer|
        user_answer.destroy
      end

      params[:user_answers].values.each do |answer_id|
        answer = Answer.find(answer_id)
        user_answer = UserAnswer.new(team: @team, user: user, answer: answer)
        user_answer.save
      end

      membership = Membership.find_by(user: user, team: @team)
      membership.status = 1
      membership.save

      redirect_to teams_path
    else
      render 'questions/index'
    end
  end
end
