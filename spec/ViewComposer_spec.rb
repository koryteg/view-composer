require 'spec_helper'

describe BaseComposer do
	context ".new" do
    let(:model) { double("model")}
    let(:invalid_composer) { BaseComposer.new }
    let(:valid_composer) { BaseComposer.new(model: model) }
	  it "raise error without delegatee" do
      expect{invalid_composer}.to raise_error(ArgumentError)
	  end
	  it "it initializes" do
      expect(valid_composer).to be_a(BaseComposer)
	  end
	end

  context '.attributes' do
    let(:post) { double("Post.new", name: "a post", title: "a post title") }

    it "attributes looks for instance methods in the child class first" do
      class PostComposer < BaseComposer
        attributes :name, :title
        def name
          "a post 2"
        end
      end
      post_composer = PostComposer.new(model: post)
      expect(post_composer.name).to eq("a post 2")
      expect(post_composer.title).to eq("a post title")
    end

    it 'assigns attributes from model to composer' do

      class PostComposer2 < BaseComposer
        attributes :name, :title
      end
      post_composer = PostComposer2.new(model: post)

      expect(post_composer.name).to eq("a post")
      expect(post_composer.title).to eq("a post title")
    end

    it 'uses model in method definition.' do
      class PostComposer3 < BaseComposer
        attributes :name, :title
        def name
          "#{@model.name} 3"
        end
      end
      post_composer = PostComposer3.new(model: post)
      expect(post_composer.name).to eq("a post 3")
      expect(post_composer.title).to eq("a post title")
    end
  end

  context "composed objects" do

    let(:post) { double("Post.new 2", name: "a post", title: "a post title") }
    it "takes a composeable object and assigns its methods to the composer" do
      class Acomposer < BaseComposer
      end
      class AdminStats
        def initialize(model)
          @model = model
        end

        def numbers
          123
        end

        def title
          "#{@model.title} 123"
        end
      end

      expect(AdminStats).to receive(:new).with(post).and_call_original
      composer = Acomposer.new(model: post, composable_objects: [AdminStats])
      expect(composer.numbers).to eq(123)
      expect(composer.title).to eq("a post title 123")
    end
  end

  context '#hash_attrs' do
    let(:model) { double("something", title: "a title", reddit: "a reddit" ) }
    it 'returns a hash of the attributes/methods' do
      class HashAttrs < BaseComposer
        attributes :title, :reddit
      end
      expect(HashAttrs.new(model: model).hash_attrs).to eq({title:"a title",reddit:"a reddit"})
    end
    it 'doesnt return data that is not defined in in the attributes api' do
      composer = BaseComposer.new(model: Object.new)
      expect(composer.hash_attrs).to eq({})
    end
  end

  context '#to_json' do
    let(:model) { double("something", title: "a title", reddit: "a reddit" ) }

    it 'it turns stuff into json' do
      class Thing < BaseComposer
        attributes :title, :reddit
      end
      expect(Thing.new(model: model).to_json).to eq("{\"title\":\"a title\",\"reddit\":\"a reddit\"}")
    end

    it 'doesnt return stuff that is not defined in in the attributes api' do
      composer = BaseComposer.new(model: Object.new)
      expect(composer.to_json).to eq("{}")
    end
  end

  context "attributes inherited" do
    let(:model) { double("something", title: "a title", reddit: "a reddit", id: 123 ) }
    before(:all) do
      class BaseThing < BaseComposer
        attributes :title, :reddit

        def title
          "#{@model.title} altered"
        end
      end

      class ChildThing1 < BaseThing
      end

      class ChildThing2 < BaseThing
        attributes :id
      end
    end

    it"inherited class needs to take the parent's attributes" do
      composer1 = ChildThing1.new(model: model)
      expect(composer1.title).to eq("a title altered")
      expect(composer1.reddit).to eq("a reddit")
      expect{composer1.id}.to raise_error(NoMethodError)
    end

    it 'combines both attributes in the api' do
      composer2 = ChildThing2.new(model: model)
      expect(composer2.title).to eq("a title altered")
      expect(composer2.reddit).to eq("a reddit")
      expect(composer2.id).to eq(123)
    end
  end
end
