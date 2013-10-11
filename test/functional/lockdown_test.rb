require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class LockdownTest < ActionController::TestCase
  tests StatsController

  TEMPORARY_TODOS = []

  def create_todo(date, description, tags)
    Timecop.freeze(Time.local(2013, 1, 2, 3, 4, 5)) do
      todo = Todo.create!(
        :user_id => 1,
        :context_id => 1,
        :description => description,
        :created_at => date,
        :updated_at => date,
        :tag_list => tags
      )
      TEMPORARY_TODOS << todo.id
    end
  end

  def setup
    create_todo(Date.today - 370, "eat burgers", %w(eat burger meat dinner))
    create_todo(Date.today - 29, "eat bananas", %w(eat banana fruit snack))
    create_todo(Date.today - 6, "eat candy", %w(eat candy snack desert))

    FileUtils.mkdir_p('.lockdown')
    FileUtils.touch('.lockdown/approved.html')
  end

  def teardown
    TEMPORARY_TODOS.each do |id|
      Todo.find(id).destroy
    end
  end

  def test_page_does_not_change_while_refactoring
    login_as(:admin_user)

    Timecop.freeze(Time.local(2013, 1, 2, 3, 4, 5)) do
      get :index
    end
    approved = File.read('.lockdown/approved.html')
    received = @response.body
    File.open('.lockdown/received.html', 'w') do |f|
      f.puts received
    end
    unless approved == received
      assert false, "FAIL:\n\tThe output changed.\n\ttry this:\n\n\tdiff .lockdown/approved.html .lockdown/received.html\n\nIf you like the received.html output, go ahead and\n\n\tcp .lockdown/received.html .lockdown/approved.html"
    end
  end
end
