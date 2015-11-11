require 'rails_helper'

RSpec.describe PPlan::Step, type: :model do

  it 'has a valid factory' do
    step = FactoryGirl.create(:step_with_plan)
    expect(step).to be_truthy
    step.plan.destroy
  end

  describe '.create' do 
    before :context do
      @step = FactoryGirl.create(:step_with_plan)
    end
  
    after :context do
      PPlan::Plan.find(@step.plan_id).destroy
    end
  
    subject { @step }
  
    it { is_expected.to be_instance_of PPlan::Step }
    it { is_expected.to be_kind_of ActiveFedora::Base }
    
    it 'sets title' do
      expect(subject.title).to eql 'Check citation'
    end
    
    it 'sets description' do
      expect(subject.description).to eql 'Ensure citation is correct.'
    end

    it 'sets plan' do
      expect(subject.plan).to be_instance_of PPlan::Plan
    end
  end

  describe 'associations' do
    describe '#next' do
      before :context do
        @step = FactoryGirl.create(:step_with_plan)
        @next_step = FactoryGirl.create(:step, plan: @step.plan,
                                        title: 'Next Step')
        @step.next << @next_step
        @step.save
      end

      after :context do
        PPlan::Plan.find(@step.plan_id).destroy
      end
    
      it 'sets next step' do
        expect(@step.next.size).to eql 1
        expect(@step.next.first).to eq @next_step
      end

      it 'sets previous step in new step' do
        expect(@next_step.previous).to eq @step
      end
    end

    describe '#previous' do
      before :context do
        @step = FactoryGirl.create(:step_with_plan)
        @previous_step = FactoryGirl.create(:step, plan: @step.plan,
                                            title: 'Previous Step')
        @step.previous = @previous_step
        @step.save
      end

      after :context do
        PPlan::Plan.find(@step.plan_id).destroy
      end
      
      it 'sets previous' do
        expect(@step.previous).to eq @previous_step
      end
      
      it 'sets next in new step' do
        expect(@previous_step.next.first).to eq @step
      end
    end
  end

  describe 'validations' do
    before :example do
      @step = FactoryGirl.create(:step_with_plan)
      @plan_id = @step.plan_id
    end
    
    after :example do
      PPlan::Plan.find(@plan_id).destroy
    end

    subject { @step }

    it 'assure there is a title' do
      subject.title = nil
      expect(subject.save).to be false
    end
    
    it 'assure there is a description' do
      subject.description = nil
      expect(subject.save).to be false
    end
    
    it 'assure there is a plan' do
      subject.plan = nil
      expect(subject.save).to be false
    end

    it 'assure there is 0 or 1 next step' do
      @step_two = FactoryGirl.create(:step, plan: subject.plan,
                                     title: 'Step Two')
      @step_three = FactoryGirl.create(:step, plan: subject.plan,
                                       title: 'Step Three')
      subject.next << @step_two
      expect(subject.save).to be true
      subject.next << @step_three
      expect(subject.save).to be false
    end

    # A step can't be set to the previous of two different steps.
    it 'assure previous isn\'t set as previous step for different step' do
      @step_one = FactoryGirl.create(:step, plan: subject.plan,
                                     title: 'Step One')
      @step_two = FactoryGirl.create(:step, plan: subject.plan,
                                     title: 'Step Two', previous: @step_one)
      subject.previous = @step_one
      expect(subject.save).to be false
    end
  end
end