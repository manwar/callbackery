% my $p = shift;
package <%= $p->{class} %>::GuiPlugin::Song;
use Mojo::Base 'CallBackery::GuiPlugin::AbstractTable';
use CallBackery::Translate qw(trm);
use CallBackery::Exception qw(mkerror);

=head1 NAME

<%= $p->{class} %>::GuiPlugin::Song - Song Table

=head1 SYNOPSIS

 use <%= $p->{class} %>::GuiPlugin::Song;

=head1 DESCRIPTION

The Song Table Gui.

=cut


=head1 METHODS

All the methods of L<CallBackery::GuiPlugin::AbstractTable> plus:

=cut

has formCfg => sub {
    my $self = shift;
    my $db = $self->user->db;

    return [
        {
            key => 'song_title',
            widget => 'text',
            set => {
                placeholder => 'Song Title',
            },
        },
    ]
};

=head2 tableCfg


=cut

has tableCfg => sub {
    my $self = shift;
    return [
        {
            label => trm('Id'),
            type => 'str',
            width => '1*',
            key => 'song_id',
            sortable => $self->true,
            primary => $self->true
        },
        {
            label => trm('Title'),
            type => 'str',
            width => '6*',
            key => 'song_title',
            sortable => $self->true,
        },
        {
            label => trm('Voices'),
            type => 'str',
            width => '1*',
            key => 'song_voices',
            sortable => $self->true,
        },
        {
            label => trm('Composer'),
            type => 'str',
            width => '2*',
            key => 'song_composer',
            sortable => $self->true,
        },
        {
            label => trm('Page'),
            type => 'str',
            width => '1*',
            key => 'song_page',
            sortable => $self->true,
        },
        {
            label => trm('Note'),
            type => 'str',
            width => '3*',
            key => 'song_note',
            sortable => $self->true,
        },
     ]
};

=head2 actionCfg

Only users who can write get any actions presented.

=cut

has actionCfg => sub {
    my $self = shift;
    return [] if $self->user and not $self->user->may('write');

    return [
        {
            label => trm('Add Song'),
            action => 'popup',
            addToContextMenu => $self->true,
            name => 'songFormAdd',
            popupTitle => trm('New Song'),
            backend => {
                plugin => 'SongForm',
                config => {
                    type => 'add'
                }
            }
        },
        {
            label => trm('Edit Song'),
            action => 'popup',
            addToContextMenu => $self->true,
            defaultAction => $self->true,
            name => 'songFormEdit',
            popupTitle => trm('Edit Song'),
            backend => {
                plugin => 'SongForm',
                config => {
                    type => 'edit'
                }
            }
        },
        {
            label => trm('Delete Song'),
            action => 'submitVerify',
            addToContextMenu => $self->true,
            question => trm('Do you really want to delete the selected Song '),
            key => 'delete',
            handler => sub {
                my $args = shift;
                my $id = $args->{selection}{song_id};
                die mkerror(4992,"You have to select a song first")
                    if not $id;
                my $db = $self->user->db;
                if ($db->deleteData('song',$id) == 1){
                    return {
                         action => 'reload',
                    };
                }
                die mkerror(4993,"Faild to remove song $id");
                return {};
            }
        }
    ];
};

sub dbh {
    shift->user->mojoSqlDb->dbh;
};

sub _getFilter {
    my $self = shift;
    my $search = shift;
    my $filter = '';
    if ( $search ){
        $filter = "WHERE song_title LIKE ".$self->dbh->quote('%'.$search);
    }
    return $filter;
}

sub getTableRowCount {
    my $self = shift;
    my $args = shift;
    my $filter = $self->_getFilter($args->{formData}{song_title});
    return ($self->dbh->selectrow_array("SELECT count(song_id) FROM song $filter"))[0];
}

sub getTableData {
    my $self = shift;
    my $args = shift;
    my $filter = $self->_getFilter($args->{formData}{song_title});
    my $SORT ='';
    if ($args->{sortColumn}){
        $SORT = 'ORDER BY '.$self->dbh->quote_identifier($args->{sortColumn});
        $SORT .= $args->{sortDesc} ? ' DESC' : ' ASC';
    }
    return $self->dbh->selectall_arrayref(<<"SQL",{Slice => {}}, $args->{lastRow}-$args->{firstRow}+1,$args->{firstRow});
SELECT *
FROM song
$filter
$SORT
LIMIT ? OFFSET ?
SQL
}

1;
__END__

=head1 COPYRIGHT

Copyright (c) <%= $p->{year} %> by <%= $p->{fullName} %>. All rights reserved.

=head1 AUTHOR

S<Tobias Oetiker E<lt>tobi@oetiker.chE<gt>>

=head1 HISTORY

 <%= "$p->{date} $p->{userName}" %> 0.0 first version

=cut
