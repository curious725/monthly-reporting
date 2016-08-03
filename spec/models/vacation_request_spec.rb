require 'rails_helper'

RSpec.describe VacationRequest do
  it 'has a valid factory' do
    vacation_request = FactoryGirl.build(:vacation_request)

    expect(vacation_request).to be_valid
  end

  context 'as a brand new object' do
    let(:vacation_request) { VacationRequest.new }

    it { expect(vacation_request).to have_attributes kind: 'planned' }
    it { expect(vacation_request).to have_attributes status: 'requested' }
    it { expect(vacation_request).to have_attributes end_date: nil }
    it { expect(vacation_request).to have_attributes start_date: nil }
    it { expect(vacation_request).to have_attributes user_id: nil }

    it { expect(vacation_request).not_to be_valid }
  end

  it 'allows to pass date in ISO 8601 format, that is, YYYY-MM-DD' do
    vacation_request = build(:vacation_request, start_date: '2017-05-01')

    expect(vacation_request).to be_valid
  end

  it 'allows to pass date as a Ruby Date object' do
    vacation_request = build(:vacation_request)
    record = YAML.load(vacation_request.to_json)

    expect { VacationRequest.create(record) }.not_to raise_exception
  end

  it 'destroys all the records of dependant models' do
    expect(VacationRequest.count).to eq(0)
    expect(ApprovalRequest.count).to eq(0)

    team = create(:team, :with_users, number_of_members: 1)
    member = team.team_roles.members.first.user
    manager = team.team_roles.managers.first.user
    vacation_request = build(:vacation_request)
    attrs = vacation_request.attributes.except('id')
    vacation_request = member.vacation_requests.create(attrs)
    vacation_request.approval_requests.create(manager_id: manager.id)

    expect(VacationRequest.count).to eq(1)
    expect(ApprovalRequest.count).to eq(1)
    expect(vacation_request.approval_requests.count).to eq(1)

    expect { vacation_request.destroy }.not_to raise_exception

    expect(VacationRequest.count).to eq(0)
    expect(ApprovalRequest.count).to eq(0)
  end

  describe 'with "status=used"' do
    it 'does not allow to pass "end_date" as incorrect date string' do
      vacation_request = build(:vacation_request, :invalid, status: 'used')

      expect(vacation_request).not_to be_valid
    end
  end

  describe '.cannot_intersect_with_other_vacations' do
    let(:user) { FactoryGirl.create(:user) }
    let(:another_user) { FactoryGirl.create(:user) }
    let(:vacation_request) { FactoryGirl.build(:vacation_request) }

    before do
      vacation_request.start_date = '2015-09-01'
      vacation_request.end_date   = '2015-09-21'
      vacation_request.user = user
      vacation_request.validate
    end

    describe 'for the very first vacation request' do
      it 'does not set any errors' do
        expect(vacation_request.errors).to be_empty
        expect(vacation_request).to be_valid
      end
    end

    context 'when user has other vacation requests' do
      describe 'without intersections' do
        before do
          create(:vacation_request,
                 user: user,
                 start_date: '2015-08-22', end_date: '2015-08-30')
          create(:vacation_request,
                 user: user,
                 start_date: '2015-09-22', end_date: '2015-09-25')

          vacation_request.validate
        end

        it 'does not set any errors' do
          expect(vacation_request.errors).to be_empty
          expect(vacation_request).to be_valid
        end
      end

      describe 'with intersections on start bound' do
        before do
          create(:vacation_request,
                 user: user,
                 start_date: '2015-08-22', end_date: '2015-09-01')

          vacation_request.validate
        end

        it 'sets error' do
          expect(vacation_request.errors).not_to be_empty
          expect(vacation_request).not_to be_valid
        end
      end

      describe 'with intersections on end bound' do
        before do
          create(:vacation_request,
                 user: user,
                 start_date: '2015-09-21', end_date: '2015-09-25')

          vacation_request.validate
        end

        it 'sets error' do
          expect(vacation_request.errors).not_to be_empty
          expect(vacation_request).not_to be_valid
        end
      end

      describe 'with intersections on both bounds' do
        before do
          create(:vacation_request,
                 user: user,
                 start_date: '2015-08-22', end_date: '2015-09-01')
          create(:vacation_request,
                 user: user,
                 start_date: '2015-09-21', end_date: '2015-09-25')

          vacation_request.validate
        end

        it 'sets error' do
          expect(vacation_request.errors).not_to be_empty
          expect(vacation_request).not_to be_valid
        end
      end

      describe 'with inner intersection' do
        before do
          create(:vacation_request,
                 user: user,
                 start_date: '2015-09-05', end_date: '2015-09-15')

          vacation_request.validate
        end

        it 'sets error' do
          expect(vacation_request.errors).not_to be_empty
          expect(vacation_request).not_to be_valid
        end
      end

      describe 'with outer intersection' do
        before do
          create(:vacation_request,
                 user: user,
                 start_date: '2015-08-30', end_date: '2015-09-25')

          vacation_request.validate
        end

        it 'sets error' do
          expect(vacation_request.errors).not_to be_empty
          expect(vacation_request).not_to be_valid
        end
      end

      context 'with any kind of intersections' do
        describe 'with status="cancelled"' do
          before do
            create(:vacation_request,
                   user: user,
                   start_date: '2015-08-30', end_date: '2015-09-25',
                   status: VacationRequest.statuses[:cancelled])
            vacation_request.validate
          end

          it 'does not set any errors' do
            expect(vacation_request.errors).to be_empty
            expect(vacation_request).to be_valid
          end
        end

        describe 'with status="declined"' do
          before do
            create(:vacation_request,
                   user: user,
                   start_date: '2015-08-30', end_date: '2015-09-25',
                   status: VacationRequest.statuses[:declined])
            vacation_request.validate
          end

          it 'does not set any errors' do
            expect(vacation_request.errors).to be_empty
            expect(vacation_request).to be_valid
          end
        end
      end
    end

    context 'when another user has vacation requests' do
      describe 'without intersections' do
        before do
          create(:vacation_request,
                 user: another_user,
                 start_date: '2015-08-22', end_date: '2015-08-30')
          create(:vacation_request,
                 user: another_user,
                 start_date: '2015-09-22', end_date: '2015-09-25')
        end

        it 'does not set any errors' do
          expect(vacation_request.errors).to be_empty
          expect(vacation_request).to be_valid
        end
      end

      describe 'with intersections on start bound' do
        before do
          create(:vacation_request,
                 user: another_user,
                 start_date: '2015-08-22', end_date: '2015-09-01')
        end

        it 'does not set any errors' do
          expect(vacation_request.errors).to be_empty
          expect(vacation_request).to be_valid
        end
      end

      describe 'with intersections on end bound' do
        before do
          create(:vacation_request,
                 user: another_user,
                 start_date: '2015-09-21', end_date: '2015-09-25')
        end

        it 'does not set any errors' do
          expect(vacation_request.errors).to be_empty
          expect(vacation_request).to be_valid
        end
      end

      describe 'with intersections on both bounds' do
        before do
          create(:vacation_request,
                 user: another_user,
                 start_date: '2015-08-22', end_date: '2015-09-01')
          create(:vacation_request,
                 user: another_user,
                 start_date: '2015-09-21', end_date: '2015-09-25')
        end

        it 'does not set any errors' do
          expect(vacation_request.errors).to be_empty
          expect(vacation_request).to be_valid
        end
      end

      describe 'with inner intersection' do
        before do
          create(:vacation_request,
                 user: another_user,
                 start_date: '2015-09-05', end_date: '2015-09-15')
        end

        it 'does not set any errors' do
          expect(vacation_request.errors).to be_empty
          expect(vacation_request).to be_valid
        end
      end

      describe 'with outer intersection' do
        before do
          create(:vacation_request,
                 user: another_user,
                 start_date: '2015-08-30', end_date: '2015-09-25')

          vacation_request.validate
        end

        it 'sets error' do
          expect(vacation_request.errors).to be_empty
          expect(vacation_request).to be_valid
        end
      end
    end
  end

  describe '.duration', focus: true do
    let(:result) { vacation.duration(Holiday.dates) }
    let(:vacation) do
      build(:vacation_request,
            start_date: '2015-10-01', end_date: '2015-10-10')
    end
    let(:duration) { 10 }
    let(:weekends) { 3 }
    let(:holidays) { 0 }
    let(:expectation) { duration - weekends - holidays }

    shared_examples 'a good boy' do
      it 'and returns correct result' do
        expect(result).to eq(expectation)
      end
    end

    context 'when there is no holidays, and no weekends' do
      let(:duration) { 5 }
      let(:weekends) { 0 }
      let(:vacation) do
        build(:vacation_request,
              start_date: '2015-10-05', end_date: '2015-10-09')
      end

      it_behaves_like 'a good boy'
    end

    context 'when there are weekends' do
      it_behaves_like 'a good boy'
    end

    context 'when there are weekends, and a weekday holiday for a day,' do
      let(:holidays) { 1 }
      before do
        create(:holiday, start: vacation.start_date + 5.days)
      end
      it_behaves_like 'a good boy'
    end

    context 'when there are weekends, and a weekday holiday for two days,' do
      let(:holidays) { 2 }
      before do
        create(:holiday, start: vacation.start_date + 5.days, duration: 2)
      end
      it_behaves_like 'a good boy'
    end

    context 'when there are weekends, and a weekday holiday for three days,' do
      let(:holidays) { 3 }
      before do
        create(:holiday, start: vacation.start_date + 5.days, duration: 3)
      end
      it_behaves_like 'a good boy'
    end

    context 'when there are weekends, and a weekend holiday for a day,' do
      let(:holidays) { 0 }
      before do
        create(:holiday, start: vacation.start_date + 2.days)
      end
      it_behaves_like 'a good boy'
    end

    context 'when there are weekends, and a weekend holiday for two days,' do
      let(:holidays) { 0 }
      before do
        create(:holiday, start: vacation.start_date + 2.days, duration: 2)
      end
      it_behaves_like 'a good boy'
    end

    context 'when there are weekends, and a weekend holiday for three days,' do
      let(:holidays) { 1 }
      before do
        create(:holiday, start: vacation.start_date + 2.days, duration: 3)
      end
      it_behaves_like 'a good boy'
    end
  end

  describe '.overlaps?' do
    let(:vacation) do
      FactoryGirl.build(:vacation_request,
                        start_date: '2015-09-05',
                        end_date: '2015-09-15')
    end

    context 'when vacation is surrounded' do
      let(:another) do
        FactoryGirl.build(:vacation_request,
                          start_date: '2015-09-01',
                          end_date: '2015-09-20')
      end

      it 'returns :true' do
        expect(vacation.overlaps?(another)).to be_truthy
      end
    end

    context 'when another vacation is surrounded' do
      let(:another) do
        FactoryGirl.build(:vacation_request,
                          start_date: '2015-09-06',
                          end_date: '2015-09-10')
      end

      it 'returns :true' do
        expect(vacation.overlaps?(another)).to be_truthy
      end
    end

    context 'when vacation overlaps only by start date' do
      let(:another) do
        FactoryGirl.build(:vacation_request,
                          start_date: '2015-09-01',
                          end_date: '2015-09-10')
      end

      it 'returns :true' do
        expect(vacation.overlaps?(another)).to be_truthy
      end
    end

    context 'when vacation overlaps only by end date' do
      let(:another) do
        FactoryGirl.build(:vacation_request,
                          start_date: '2015-09-10',
                          end_date: '2015-09-20')
      end

      it 'returns :true' do
        expect(vacation.overlaps?(another)).to be_truthy
      end
    end

    context 'when vacation and another vacation overlap by start-end dates' do
      let(:another) do
        FactoryGirl.build(:vacation_request,
                          start_date: '2015-09-01',
                          end_date: '2015-09-05')
      end

      it 'returns :true' do
        expect(vacation.overlaps?(another)).to be_truthy
      end
    end

    context 'when vacation and another vacation overlap by end-start dates' do
      let(:another) do
        FactoryGirl.build(:vacation_request,
                          start_date: '2015-09-15',
                          end_date: '2015-09-20')
      end

      it 'returns :true' do
        expect(vacation.overlaps?(another)).to be_truthy
      end
    end

    context 'when vacations do not overlap' do
      let(:earlier) do
        FactoryGirl.build(:vacation_request,
                          start_date: '2015-09-01',
                          end_date: '2015-09-04')
      end

      let(:later) do
        FactoryGirl.build(:vacation_request,
                          start_date: '2015-09-16',
                          end_date: '2015-09-23')
      end

      it 'returns :false' do
        expect(vacation.overlaps?(earlier)).to  be_falsy
        expect(vacation.overlaps?(later)).to    be_falsy
      end
    end
  end

  describe '.requested_accepted_inprogress' do
    let(:user) { create :user, :with_vacations_of_all_statuses }

    it 'provides accordingly filtered list of vacation requests' do
      expect(user.vacation_requests.count).to eq(6)
      expect(VacationRequest.requested_accepted_inprogress.count).to eq(3)
    end
  end

  describe '.team_vacations' do
    let(:boy)   { create :user, :with_vacations_of_all_statuses }
    let(:girl)  { create :user, email: 'lady_in_red@i.ua' }
    let(:team)  { create :team }

    before do
      create :vacation_request, user: girl
      create :team_role, team: team, user: boy
      create :team_role, team: team, user: girl
    end

    it 'provides list of vacation requests for users of specified team' do
      expect(VacationRequest.team_vacations(team).length).to eq(7)
    end
  end

  context 'validations' do
    it { should define_enum_for(:kind) }
    it { should define_enum_for(:status) }

    it { should validate_presence_of(:kind) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:user) }

    it 'should ensure inclusion of end_date in proper range' do
      vacation_request = build(:vacation_request)
      vacation_request.end_date = '2013-08-31'
      expect(vacation_request).to be_invalid

      vacation_request.end_date = '2050-01-02'
      expect(vacation_request).to be_invalid

      vacation_request.end_date = '2050-01-01'
      expect(vacation_request).to be_valid
    end

    it do
      should validate_inclusion_of(:end_date)
        .in_range(Date.new(2013, 9, 1)..Date.new(2050, 1, 1))
    end
  end

  context 'associations' do
    it { should have_many(:approval_requests) }
    it { should belong_to(:user) }
  end
end
