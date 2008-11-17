require File.dirname(__FILE__) + '/../test_helper'

class NodeTagTest < Test::Unit::TestCase
  fixtures :current_node_tags, :current_nodes
  set_fixture_class :current_nodes => Node
  set_fixture_class :current_node_tags => NodeTag
  
  def test_tag_count
    assert_equal 6, NodeTag.count
    node_tag_count(:visible_node, 1)
    node_tag_count(:invisible_node, 1)
    node_tag_count(:used_node_1, 1)
    node_tag_count(:used_node_2, 1)
    node_tag_count(:node_with_versions, 2)
  end
  
  def node_tag_count (node, count)
    nod = current_nodes(node)
    assert_equal count, nod.node_tags.count
  end
  
  def test_length_key_valid
    key = "k"
    (0..255).each do |i|
      tag = NodeTag.new
      tag.id = current_node_tags(:t1).id
      tag.k = key*i
      tag.v = "v"
      assert_valid tag
    end
  end
  
  def test_length_value_valid
    val = "v"
    (0..255).each do |i|
      tag = NodeTag.new
      tag.id = current_node_tags(:t1).id
      tag.k = "k"
      tag.v = val*i
      assert_valid tag
    end
  end
  
  def test_length_key_invalid
    ["k"*256].each do |i|
      tag = NodeTag.new
      tag.id = current_node_tags(:t1).id
      tag.k = i
      tag.v = "v", "Key should be too long"
      assert !tag.valid?
      assert tag.errors.invalid?(:k)
    end
  end
  
  def test_length_value_invalid
    ["k"*256].each do |i|
      tag = NodeTag.new
      tag.id = current_node_tags(:t1).id
      tag.k = "k"
      tag.v = i
      assert !tag.valid?, "Value should be too long"
      assert tag.errors.invalid?(:v)
    end
  end
  
  def test_empty_node_tag_invalid
    tag = NodeTag.new
    assert !tag.valid?, "Empty tag should be invalid"
    assert tag.errors.invalid?(:id)
  end
end
