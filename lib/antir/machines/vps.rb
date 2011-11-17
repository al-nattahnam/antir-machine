module Antir
  class Machines
    class VPS
      state_machine :state, :initial => :pending do
        before_transition :pending => :waiting do
          puts 'creating!'
        end
  
        after_transition :waiting => :created do
          puts 'created!'
        end
  
        event :create do
          #transaction do
          transition :pending => :waiting
        end
  
        event :created do
          transition :waiting => :created
        end
  
        event :ready do
          transition :created => :ready, :if => lambda { |vps| vps.ssh_ready? }
        end
      end
  
      state_machine :dns_state, :initial => :pending, :namespace => 'dns' do
        event :register do
          transition :pending => :waiting, :if => lambda { |vps| vps.created? }
        end
  
        event :registered do
          transition :waiting => :ready
        end
      end
  
      state_machine :ssh_state, :initial => :pending, :namespace => 'ssh' do
        after_transition :waiting => :ready do |vps|
          vps.ready
        end
  
        event :prepare do
          transition :pending => :waiting, :if => lambda { |vps| vps.dns_ready? }
        end
  
        event :prepared do
          transition :waiting => :ready
        end
      end
    end
  end
end
