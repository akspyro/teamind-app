class TeamsController < ApplicationController
  # Use 'authorize @team' to authorize a team and solve Pundit error

  def index
    teams = policy_scope(Team)

    @teams_open = teams.where("memberships.status = 0 OR memberships.status = 2")

    @teams_admin = teams.where("memberships.owner = true")

    @teams_member = teams.where("memberships.status = 1 AND memberships.owner = false")

  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    authorize @team
    if @team.save
      redirect_to create_team_path(:questionnaire)
    else
      render "create_team/create_team"
    end
  end

  # Wicked wizard
  # include Wicked::Wizard

  def status
    @team = Team.find(params[:id])
    authorize @team
  end

  def show
    @team = Team.find(params[:id])
    authorize @team
  end

  private

  def team_params
    params.require(:team).permit(:name, :description, :photo)
  end

end
