require File.expand_path('../helper', __FILE__)

# tests for ActionMailer bundled with Rails 3
class Mailer3Test < Test::Unit::TestCase
  
  if ActionMailer::VERSION::MAJOR >= 3
    
    require File.expand_path('../mailer/action_mailer_3/notifier', __FILE__)
    puts "\e[0m\e[32mRunning #{File.basename(__FILE__)} for action_mailer #{ActionMailer::VERSION::STRING}\e[0m"
    
    def test_create_with_no_content
      mail = Notifier.with_no_content
      assert_equal ({}), mail.arguments['content']
    end
    
    def test_create_with_simple_view
      mail = Notifier.with_simple_view
      assert_equal 'with layout simple view content', mail.arguments['content']['text/html']
    end
    
    def test_create_with_text_only_view
      mail = Notifier.with_text_only_view
      assert_equal 'text content', mail.arguments['content']['text/plain']
    end
    
    def test_create_with_html_and_text_views
      mail = Notifier.with_html_and_text_views
      assert_equal 'text content',              mail.arguments['content']['text/plain']
      assert_equal 'with layout html content',  mail.arguments['content']['text/html']
    end
    
    def test_deliver_with_html_and_text_views
      mock_successful_send
      
      assert response = Notifier.with_html_and_text_views.deliver
      assert response.is_a?(PostageApp::Response)
      assert response.ok?
    end
    
    def test_create_with_body_and_attachment_as_file
      mail = Notifier.with_body_and_attachment_as_file
      assert_equal 'manual body text', mail.arguments['content']['text/html']
      assert_equal 'text/plain', mail.arguments['attachments']['sample_file.txt']['content_type']
      assert_equal "RmlsZSBjb250ZW50\n", mail.arguments['attachments']['sample_file.txt']['content']
    end
    
    def test_create_with_body_and_attachment_as_hash
      mail = Notifier.with_body_and_attachment_as_hash
      assert_equal 'manual body text', mail.arguments['content']['text/html']
      assert_equal 'text/rich', mail.arguments['attachments']['sample_file.txt']['content_type']
      assert_equal "RmlsZSBjb250ZW50\n", mail.arguments['attachments']['sample_file.txt']['content']
    end
    
    def test_create_with_custom_postage_variables
      mail = Notifier.with_custom_postage_variables
      assert_equal ({
        'test1@test.test' => { 'name' => 'Test 1'},
        'test2@test.test' => { 'name' => 'Test 2'}
      }), mail.arguments['recipients']
      assert_equal 'test-template',             mail.arguments['template']
      assert_equal ({ 'variable' => 'value' }), mail.arguments['variables']
      assert_equal 'custom_api_key',            mail.arguments['api_key']
      assert_equal 'CustomValue1',              mail.arguments['headers']['CustomHeader1']
      assert_equal 'CustomValue2',              mail.arguments['headers']['CustomHeader2']
      assert_equal 'text content',              mail.arguments['content']['text/plain']
      assert_equal 'with layout html content',  mail.arguments['content']['text/html']
    end
    
    def test_create_with_recipient_override
      PostageApp.configuration.recipient_override = 'oleg@test.test'
      assert mail = Notifier.with_html_and_text_views
      assert_equal 'test@test.test', mail.arguments['recipients']
      assert_equal 'oleg@test.test', mail.arguments_to_send['arguments']['recipient_override']
    end
    
  else
    puts "\e[0m\e[31mSkipping #{File.basename(__FILE__)}\e[0m"
    def test_nothing ; end
  end
end