require File.join(File.dirname(__FILE__), 'helper')

context "An Ruby class having representations" do
  
  def setup
    @transformations = {
       :news_feed => Proc.new {|obj| "For the news feed: User##{obj.actor_id} #{obj.action} User##{obj.actee_id}"},
       :mini_feed => Proc.new {|obj| "For the mini feed: User##{obj.actor_id} #{obj.action} User##{obj.actee_id}"}
    }
    Action.before_save.clear
    Action.has_representations(@transformations)
    
    @action = Action.new(:actor_id => 1, :actee_id => 2, :action => "did stuff to")
  end
  
  specify "should retrieve representation of an instance, based on the representation name" do
    @action.to_representation(:news_feed).should.equal "For the news feed: User#1 did stuff to User#2"
    @action.to_representation(:mini_feed).should.equal "For the mini feed: User#1 did stuff to User#2"
  end

  specify "should set the representation if given the name" do
    @action.expects(:news_feed_representation=).with("For the news feed: User#1 did stuff to User#2")
    @action.set_representation(:news_feed)
  end
  
  specify "should raise exception if an uknown representation is requested" do
    @action.should.raise HasRepresentations::UnknownRepresentationError do
      @action.to_representation(:unknown)
    end
  end
end

context "An ActiveRecord class" do
  def setup
    @transformations = {
       :news_feed => Proc.new {|obj| "For the news feed: User##{obj.actor_id} #{obj.action} User##{obj.actee_id}"},
       :mini_feed => Proc.new {|obj| "For the mini feed: User##{obj.actor_id} #{obj.action} User##{obj.actee_id}"}
    }
    Action.before_save.clear  
    @action = Action.new(:actor_id => 1, :actee_id => 2, :action => "did stuff to")
  end
  
  specify "having representations should add a before save callback to create transformations" do
    Action.before_save.should.be.empty
    Action.has_representations(@transformations)
    
    @action.expects(:news_feed_representation=).with("For the news feed: User#1 did stuff to User#2")
    @action.expects(:mini_feed_representation=).with("For the mini feed: User#1 did stuff to User#2")
    
    Action.before_save.first.call(@action)
  end
end