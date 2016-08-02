class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token

  CannotPlusOneYourself = Class.new(StandardError)
  MissingRecipient = Class.new(StandardError)
  MissingSlackToken = Class.new(StandardError)

  def plus
    ActiveRecord::Base.transaction do
      team = Team.find_or_initialize_by(slack_team_id: params[:team_id])
      recipient_name = MessageParser.new(text_params[:text], text_params[:trigger_word]).recipient_name
      raise MissingSlackToken if team.slack_token.nil? && recipient_name.start_with?("<@")

      sender, recipient = prepare_transaction_actors.(team_params, text_params, user_params)


      raise CannotPlusOneYourself if sender == recipient
      recipient.increment!(:points)
      respond_to do |format|
        format.json do
          render json: {
                     text: "#{sender.slack_user_name}(#{sender.points}) gave +1 for #{recipient.slack_user_name}(#{recipient.points})",
                     parse: "none"
                 }
        end
      end
    end
  rescue CannotPlusOneYourself
    respond_to do |format|
      format.json do
        render json: {text: "Nope... not gonna happen."}
      end
    end
  rescue MissingSlackToken
    respond_to do |format|
      format.json do
        render json: {text: "This slack team doesn't have specified slack token(or it's invalid). Please use nickname without @"}
      end
    end
  end

  def empty
    respond_to do |format|
      format.json do
        render json: {text: "?"}
      end
    end
  end

  def stats
    msg = GetStats.new.call(team_params)
    respond_to do |format|
      format.json do
        render json: {text: msg}
      end
    end
  end

  def index
    teams = Team.preload(:team_members).limit(10)
    team = teams[0]
    team_members = team ? team.team_members.sort_by{|tm| tm.points }.reverse : []
    render locals: {teams: teams, team_members: team_members}
  end

  private
  def prepare_transaction_actors
    PrepareTransactionActors.new
  end

  def team_params
    params.slice(:team_id, :team_domain)
  end

  def text_params
    params.slice(:text, :trigger_word)
  end

  def user_params
    params.slice(:user_id, :user_name)
  end
end
